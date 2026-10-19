resource "aws_ecr_repository" "repos" {
  for_each             = toset(var.repositories)
  name                 = each.value
  image_tag_mutability = "IMMUTABLE"
  tags                 = { Env = var.environment, Name = each.value }
}
