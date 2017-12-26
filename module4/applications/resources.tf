#Based on the work from https://github.com/arbabnazar/terraform-ansible-aws-vpc-ha-wordpress

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-west-2"
}

##################################################################################
# DATA
##################################################################################
locals {
  workspace_key = "env:/${terraform.workspace}/${var.network_remote_state_key}"
}


data "terraform_remote_state" "networking" {
  backend = "s3"

  config {
    key            = "${terraform.workspace == "default" ? var.network_remote_state_key : local.workspace_key}"
    bucket         = "${var.network_remote_state_bucket}"
    region         = "us-west-2"
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
  }
}

data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-hvm-20*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

##################################################################################
# RESOURCES
##################################################################################

resource "aws_launch_configuration" "webapp_lc" {
  lifecycle {
    create_before_destroy = true
  }

  name_prefix   = "${terraform.workspace}-ddt-lc-"
  image_id      = "${data.aws_ami.aws_linux.id}"
  instance_type = "${var.instance_type}"

  security_groups = [
    "${aws_security_group.webapp_http_inbound_sg.id}",
    "${aws_security_group.webapp_ssh_inbound_sg.id}",
    "${aws_security_group.webapp_outbound_sg.id}",
  ]

  user_data                   = "${file("./templates/userdata.sh")}"
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

  tags {
    Name        = "ddt-webapp-elb"
    Environment = "${terraform.workspace}"
  }
}

resource "aws_autoscaling_group" "webapp_asg" {
  lifecycle {
    create_before_destroy = true
  }

  vpc_zone_identifier   = ["${data.terraform_remote_state.networking.public_subnets}"]
  name                  = "ddt_webapp_asg"
  max_size              = "${var.asg_max}"
  min_size              = "${var.asg_min}"
  wait_for_elb_capacity = false
  force_delete          = true
  launch_configuration  = "${aws_launch_configuration.webapp_lc.id}"
  load_balancers        = ["${aws_elb.webapp_elb.name}"]

  tag {
    key                 = "Name"
    value               = "ddt_webapp_asg"
    propagate_at_launch = "true"
  }

  tag {
    key                 = "Environment"
    value               = "${terraform.workspace}"
    propagate_at_launch = "true"
  }
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
  ami                         = "${data.aws_ami.aws_linux.id}"
  instance_type               = "${var.instance_type}"
  subnet_id                   = "${element(data.terraform_remote_state.networking.public_subnets,0)}"
  associate_public_ip_address = true
  vpc_security_group_ids      = ["${aws_security_group.bastion_ssh_sg.id}"]
  key_name                    = "${var.key_name}"

  tags {
    Name        = "ddt-bastion"
    Environment = "${terraform.workspace}"
  }
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
  allocated_storage      = "${var.rds_storage}"
  engine                 = "${var.rds_engine}"
  engine_version         = "${var.rds_engine_version}"
  instance_class         = "${var.rds_instance_class}"
  multi_az               = "${var.rds_multi_az}"
  name                   = "${var.rds_db_name}"
  username               = "${var.rds_username}"
  password               = "${var.rds_password}"
  db_subnet_group_name   = "${aws_db_subnet_group.db_subnet_group.id}"
  vpc_security_group_ids = ["${aws_security_group.rds_sg.id}"]
  skip_final_snapshot    = true

  tags {
    Environment = "${terraform.workspace}"
  }
}
