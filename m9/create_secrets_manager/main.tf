provider "aws" {
  region = var.region
}

resource "aws_secretsmanager_secret" "api_key" {
  name = "taco_wagon_dev_api_key"
}

resource "aws_secretsmanager_secret_version" "api_key" {
  secret_id     = aws_secretsmanager_secret.api_key.id
  secret_string = var.api_key
}

data "aws_iam_policy_document" "web_app_access" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.web_app.arn]
    }

    actions = ["secretsmanager:GetSecretValue"]

    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret_policy" "api_key" {
  secret_arn = aws_secretsmanager_secret.api_key.arn
  policy     = data.aws_iam_policy_document.web_app_access.json
}

resource "aws_iam_role" "web_app" {
  name = "web_app_dev_api_key_access"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}