variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "node_type" {
  type    = string
  default = "cache.t3.small"
}

variable "node_count" {
  type    = number
  default = 2
}
