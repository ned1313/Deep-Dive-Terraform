##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  region = var.region
}

##################################################################################
# LOCALS
##################################################################################

locals {

  common_tags = {
    Environment = var.environment
    BillingCode = var.billing_code
  }

  name_prefix = "${var.prefix}-${var.environment}"

}

##################################################################################
# RESOURCES
##################################################################################
resource "aws_iam_instance_profile" "main" {
  name = "${local.name_prefix}-webapp"
  role = var.ec2_role_name

  tags = local.common_tags
}

resource "aws_instance" "main" {
  count         = length(data.tfe_outputs.networking.nonsensitive_values.public_subnets)
  ami           = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type = var.instance_type
  subnet_id     = data.tfe_outputs.networking.nonsensitive_values.public_subnets[count.index]
  vpc_security_group_ids = [
    aws_security_group.webapp_http_inbound_sg.id,
    aws_security_group.webapp_ssh_inbound_sg.id,
    aws_security_group.webapp_outbound_sg.id,
  ]

  key_name = module.ssh_keys.key_pair_name

  tags = merge(local.common_tags, {
    "Name" = "${local.name_prefix}-webapp-${count.index}"
  })

  user_data = templatefile("${path.module}/templates/userdata.sh", {
    playbook_repository = var.playbook_repository
    secret_id           = var.api_key_secret_id
    host_list_ssm_name  = local.host_list_ssm_name
    site_name_ssm_name  = local.site_name_ssm_name
  })

  user_data_replace_on_change = true
  iam_instance_profile        = aws_iam_instance_profile.main.name

}

resource "aws_lb" "main" {
  name               = "${local.name_prefix}-webapp"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.webapp_http_inbound_sg.id]
  subnets            = data.tfe_outputs.networking.nonsensitive_values.public_subnets

  enable_deletion_protection = false

  tags = local.common_tags
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

resource "aws_lb_target_group" "main" {
  name        = "${local.name_prefix}-webapp"
  port        = 80
  target_type = "instance"
  protocol    = "HTTP"
  vpc_id      = data.tfe_outputs.networking.nonsensitive_values.vpc_id
}

resource "aws_alb_target_group_attachment" "main" {
  count            = length(aws_instance.main.*.id)
  target_group_arn = aws_lb_target_group.main.arn
  target_id        = aws_instance.main[count.index].id
}