variable "github_oidc_provider_arn" { type = string }
variable "github_repo" { type = string }
variable "github_deploy_branch" {
  type    = string
  default = "main"
}

variable "name_prefix" { type = string }
variable "environment" { type = string }
