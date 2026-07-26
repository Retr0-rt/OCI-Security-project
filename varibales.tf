variable "compartment_id" {
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
  default = "10.0.1.0/24"
}

variable "private_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "web_port" {
  type    = number
  default = 80
}

variable "db_port" {
  type    = number
  default = 1521
}

variable "ssh_public_key" {
  type = string
}
