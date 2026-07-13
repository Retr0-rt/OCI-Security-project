resource "oci_core_vcn" "security_vcn" {
  compartment_id = var.compartemt_id
  cidr_block = var.vcn_cidr
  display_name = "VCN_Stage26"
  dns_label = "stage26"
  is_ipv6enabled = false
}