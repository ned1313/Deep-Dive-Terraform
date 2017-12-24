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

data "terraform_remote_state" "networking" {
  backend = "s3"
  config {
    key = "${var.network_remote_state_key}"
    bucket = "${var.network_remote_state_bucket}"
    region = "us-west-2"
    aws_access_key = "${var.aws_access_key}"
    aws_secret_key = "${var.aws_secret_key}"
  }
}

data "aws_ami" "aws_linux" {
  most_recent = true

  filter {
    name = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name = "name"
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
  lifecycle { create_before_destroy = true }
  image_id = "${data.aws_ami.aws_linux.id}"
  instance_type = "${var.instance_type}"
  security_groups = [
    "${aws_security_group.webapp_http_inbound_sg.id}",
    "${aws_security_group.webapp_ssh_inbound_sg.id}",
    "${aws_security_group.webapp_outbound_sg.id}"
  ]
  user_data = "${file("./templates/userdata.sh")}"
  key_name = "${var.key_name}"
  associate_public_ip_address = true
}

resource "aws_elb" "webapp_elb" {
  name = "demo-webapp-elb"
  subnets = ["${data.terraform_remote_state.networking.public_subnets}"]
  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "HTTP:80/"
    interval = 10
  }
  security_groups = ["${aws_security_group.webapp_http_inbound_sg.id}"]
  tags {
      Name = "terraform_elb"
  }
}

resource "aws_autoscaling_group" "webapp_asg" {
  lifecycle { create_before_destroy = true }
  vpc_zone_identifier = ["${data.terraform_remote_state.networking.public_subnets}"]
  name = "demo_webapp_asg-${var.webapp_lc_name}"
  max_size = "${var.asg_max}"
  min_size = "${var.asg_min}"
  wait_for_elb_capacity = false
  force_delete = true
  launch_configuration = "${aws_launch_configuration.webapp_lc.id}"
  load_balancers = ["${aws_elb.webapp_elb.name}"]
  tag {
    key = "Name"
    value = "terraform_asg"
    propagate_at_launch = "true"
  }
}

#
# Scale Up Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_up" {
  name = "terraform_asg_scale_up"
  scaling_adjustment = 2
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.webapp_asg.name}"
}
resource "aws_cloudwatch_metric_alarm" "scale_up_alarm" {
  alarm_name = "terraform-demo-high-asg-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "80"
  insufficient_data_actions = []
  dimensions {
      AutoScalingGroupName = "${aws_autoscaling_group.webapp_asg.name}"
  }
  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.scale_up.arn}"]
}

#
# Scale Down Policy and Alarm
#
resource "aws_autoscaling_policy" "scale_down" {
  name = "terraform_asg_scale_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 600
  autoscaling_group_name = "${aws_autoscaling_group.webapp_asg.name}"
}

resource "aws_cloudwatch_metric_alarm" "scale_down_alarm" {
  alarm_name = "terraform-demo-low-asg-cpu"
  comparison_operator = "LessThanThreshold"
  evaluation_periods = "5"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "30"
  insufficient_data_actions = []
  dimensions {
      AutoScalingGroupName = "${aws_autoscaling_group.webapp_asg.name}"
  }
  alarm_description = "EC2 CPU Utilization"
  alarm_actions = ["${aws_autoscaling_policy.scale_down.arn}"]
}

resource "aws_instance" "bastion" {
  ami = "${data.aws_ami.aws_linux.id}"
  instance_type = "${var.instance_type}"
  tags = {
    Name = "terraform_bastion"
  }
  subnet_id = "${element(data.terraform_remote_state.networking.public_subnets,0)}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.bastion_ssh_sg.id}"]
  key_name = "${var.key_name}"
}

resource "aws_eip" "bastion" {
  instance = "${aws_instance.bastion.id}"
  vpc = true
}

resource "aws_instance" "private_subnet_instance" {
  ami = "${data.aws_ami.aws_linux.id}"
  instance_type = "${var.instance_type}"
  tags = {
    Name = "terraform_demo_private_subnet"
  }
  subnet_id = "${element(data.terraform_remote_state.networking.private_subnets,0)}"
  vpc_security_group_ids = [
    "${aws_security_group.ssh_from_bastion_sg.id}",
    "${aws_security_group.web_access_from_nat_sg.id}"
    ]
  key_name = "${var.key_name}"
}

output "private_subnets" {
    value = "${data.terraform_remote_state.networking.private_subnets}"
}