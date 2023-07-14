output "role_name" {
  value = aws_iam_role.web_app.name
}

output "secret_id" {
  value = aws_secretsmanager_secret.api_key.id
}