variable "compartemt_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vcn_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_cidr" {
  type    = string
  default = "10.0.1.0/16"
}

variable "private_cidr" {
  type    = string
  default = "10.0.2.0/16"
}

variable "web_port" {
  type = number
  default = 443
}

variable "db_port" {
  type = number
  default = 1521
}