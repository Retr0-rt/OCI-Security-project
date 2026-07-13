variable "compartemt_id" {
  type = string
}

variable "region" {
  type = string
}

variable "vcn_cidr" {
  type = string
  default = "10.0.0.0/16"
}