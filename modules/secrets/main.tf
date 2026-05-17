resource "aws_secretsmanager_secret" "secrets" {
  for_each = var.secrets
  name = "${var.name_prefix}-${each.key}-${var.environment}"
  description = each.value.description
}

resource "aws_secretsmanager_secret_version" "values" {
  for_each = var.secrets
  secret_id = aws_secretsmanager_secret.secrets[each.key].id
  secret_string = each.value.value_json
}
