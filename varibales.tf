variable "tenancy_id" {
  type = string
}
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
  default = 5432
}

variable "ssh_public_key" {
  type = string
}

variable "alert_email_address" {
  type = string
}

variable "configuration_detector_recipe_id" {
  description = "OCID of the Oracle-managed OCI Configuration Detector Recipe"
  type        = string
}

variable "threat_detector_recipe_id" {
  description = "OCID of the Oracle-managed OCI Threat Detector Recipe"
  type        = string
}

variable "responder_recipe_id" {
  description = "OCID of the Oracle-managed OCI Responder Recipe"
  type        = string
}