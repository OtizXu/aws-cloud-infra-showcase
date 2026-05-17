variable "name_prefix" { type = string }
variable "environment" { type = string }
variable "secrets" { type = map(object({ description = string, value_json = string })) }
