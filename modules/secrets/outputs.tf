output "secret_ids" { value = aws_secretsmanager_secret.secrets[*].id }
