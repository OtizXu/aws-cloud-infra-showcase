variable "rds_master_secret_arn" {
  type    = string
  default = ""
}

variable "rds_master_password" {
  type    = string
  default = ""
}

variable "rds_master_username" {
  type    = string
  default = "vibe_admin"
}

variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "engine_version" {
  type    = string
  default = "14.9"
}

variable "rds_security_group_id" {
  type    = string
  default = ""
}
