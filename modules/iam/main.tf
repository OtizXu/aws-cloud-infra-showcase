data "aws_iam_policy_document" "oidc_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type = "Federated"
      identifiers = [var.github_oidc_provider_arn]
    }
    actions = ["sts:AssumeRoleWithWebIdentity"]
    condition {
      test = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = ["repo:${var.github_repo}:ref:refs/heads/${var.github_deploy_branch}"]
    }
  }
}

resource "aws_iam_role" "github_actions_role" {
  name = "${var.name_prefix}-gh-actions-${var.environment}"
  assume_role_policy = data.aws_iam_policy_document.oidc_assume_role.json
}

resource "aws_iam_role_policy" "ci_policy" {
  name = "${var.name_prefix}-gh-actions-policy-${var.environment}"
  role = aws_iam_role.github_actions_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:*",
          "dynamodb:*",
          "kms:Decrypt",
          "iam:PassRole",
          "ecs:Describe*",
          "ecs:UpdateService",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "cloudfront:CreateInvalidation",
          "rds:Describe*",
          "secretsmanager:GetSecretValue",
          "ssm:GetParameter"
        ],
        Resource = "*"
      }
    ]
  })
}
