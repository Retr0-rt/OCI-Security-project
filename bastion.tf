resource "oci_bastion_bastion" "main_bastion" {
  compartment_id = var.compartment_id
  bastion_type   = "STANDARD"
  name           = "Batsion_Service_St26"

  target_subnet_id             = oci_core_subnet.public_subnet.id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  max_session_ttl_in_seconds   = 10800
}