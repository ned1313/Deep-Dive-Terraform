#Based on the work from https://github.com/arbabnazar/terraform-ansible-aws-vpc-ha-wordpress

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  profile = "${var.aws_profile}"
  region  = "us-west-2"
}

##################################################################################
# RESOURCES
##################################################################################
data "template_file" "userdata" {
  template = "${file("templates/userdata.sh")}"

  vars {
    wp_db_hostname   = "${aws_db_instance.rds.endpoint}"
    wp_db_name = "${terraform.workspace}${data.external.configuration.result.rds_db_name}"
    wp_db_user            = "${var.rds_username}"
    wp_db_password = "${var.rds_password}"
    playbook_repository = "${var.playbook_repository}"
  }
}

resource "aws_launch_configuration" "webapp_lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix   = "${terraform.workspace}-ddt-lc-"
  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "${data.external.configuration.result.asg_instance_size}"

  security_groups = [
    "${aws_security_group.webapp_http_inbound_sg.id}",
    "${aws_security_group.webapp_ssh_inbound_sg.id}",
    "${aws_security_group.webapp_outbound_sg.id}",
  ]

  user_data                   = "${data.template_file.userdata.rendered}"
  key_name                    = "${var.key_name}"
  associate_public_ip_address = true
}

resource "aws_elb" "webapp_elb" {
  name    = "ddt-webapp-elb"
  subnets = ["${data.terraform_remote_state.networking.public_subnets}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }

  security_groups = ["${aws_security_group.webapp_http_inbound_sg.id}"]

  tags = "${local.common_tags}"
}

resource "aws_autoscaling_group" "webapp_asg" {
  lifecycle {
    create_before_destroy = true
  }

  vpc_zone_identifier   = ["${data.terraform_remote_state.networking.public_subnets}"]
  name                  = "ddt_webapp_asg"
  max_size              = "${data.external.configuration.result.asg_max_size}"
  min_size              = "${data.external.configuration.result.asg_min_size}"
  wait_for_elb_capacity = false
  force_delete          = true
  launch_configuration  = "${aws_launch_configuration.webapp_lc.id}"
  load_balancers        = ["${aws_elb.webapp_elb.name}"]

  tags = ["${
    list(
      map("key", "Name", "value", "ddt_webapp_asg", "propagate_at_launch", true),
      map("key", "environment", "value", "${data.external.configuration.result.environment}", "propagate_at_launch", true),
      map("key", "billing_code", "value", "${data.external.configuration.result.billing_code}", "propagate_at_launch", true),
      map("key", "project_code", "value", "${data.external.configuration.result.project_code}", "propagate_at_launch", true),
      map("key", "network_lead", "value", "${data.external.configuration.result.network_lead}", "propagate_at_launch", true),
      map("key", "application_lead", "value", "${data.external.configuration.result.application_lead}", "propagate_at_launch", true)
    )
  }"]

}

#
# Scale Up Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_up" {
  name                   = "ddt_asg_scale_up"
  scaling_adjustment     = 2
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = "${aws_autoscaling_group.webapp_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name                = "ddt-high-asg-cpu"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"
  insufficient_data_actions = []

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.webapp_asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale_up.arn}"]
}

#
# Scale Down Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_down" {
  name                   = "ddt_asg_scale_down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 600
  autoscaling_group_name = "${aws_autoscaling_group.webapp_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name                = "ddt-low-asg-cpu"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "5"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "30"
  insufficient_data_actions = []

  dimensions {
    AutoScalingGroupName = "${aws_autoscaling_group.webapp_asg.name}"
  }

  alarm_description = "EC2 CPU Utilization"
  alarm_actions     = ["${aws_autoscaling_policy.scale_down.arn}"]
}

resource "aws_instance" "bastion" {
  ami                         = "${data.aws_ami.ubuntu.id}"
  instance_type               = "${data.external.configuration.result.asg_instance_size}"
  subnet_id                   = "${element(data.terraform_remote_state.networking.public_subnets,0)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.bastion_ssh_sg.id}"]
  key_name                    = "${var.key_name}"

  tags = "${merge(
    local.common_tags,
    map(
      "Name", "ddt_bastion_host",
    )
  )}"
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc      = true
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${terraform.workspace}-ddt-rds-subnet-group"
  subnet_ids = ["${data.terraform_remote_state.networking.private_subnets}"]
}

resource "aws_db_instance" "rds" {
  identifier             = "${terraform.workspace}-ddt-rds"
  allocated_storage      = "${data.external.configuration.result.rds_storage_size}"
  engine                 = "${data.external.configuration.result.rds_engine}"
  engine_version         = "${data.external.configuration.result.rds_version}"
  instance_class         = "${data.external.configuration.result.rds_instance_size}"
  multi_az               = "${data.external.configuration.result.rds_multi_az}"
  name                   = "${terraform.workspace}${data.external.configuration.result.rds_db_name}"
  username               = "${var.rds_username}"
  password               = "${var.rds_password}"
  db_subnet_group_name   = "${aws_db_subnet_group.db_subnet_group.id}"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot    = true

  tags = "${local.common_tags}"
}
