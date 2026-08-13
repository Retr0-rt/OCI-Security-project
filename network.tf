resource "oci_core_vcn" "secure_vcn" {
  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr
  display_name   = "VCN_Stage26"
  dns_label      = "stage26"
  is_ipv6enabled = false
}

resource "oci_core_internet_gateway" "secure_igw" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  display_name   = "IGW_St26"
  enabled        = true
}

resource "oci_core_nat_gateway" "secure_ngt" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  display_name   = "NGW_St26"
}

resource "oci_core_route_table" "public_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  display_name   = "RT_Public_St26"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.secure_igw.id
  }
}

resource "oci_core_route_table" "private_route_table" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  display_name   = "RT_Private_St26"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.secure_ngt.id
  }
}

resource "oci_core_subnet" "public_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  cidr_block     = var.public_cidr
  display_name   = "Subnet_Public_St26"
  dns_label      = "public"
  route_table_id = oci_core_route_table.public_route_table.id

  #security
  security_list_ids = [oci_core_security_list.public_security_list.id]
}

resource "oci_core_subnet" "private_subnet" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  cidr_block     = var.private_cidr
  display_name   = "Subnet_Private_St26"
  dns_label      = "private"
  route_table_id = oci_core_route_table.private_route_table.id

  #security
  security_list_ids          = [oci_core_security_list.private_security_list.id]
  prohibit_public_ip_on_vnic = true
}

resource "oci_core_security_list" "public_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  display_name   = "SL_Public_St26"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  ingress_security_rules {
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    protocol    = "6" # the number for tcp 
    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_security_list" "private_security_list" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  display_name   = "SL_Private_St26"

  egress_security_rules {
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
  ingress_security_rules {
    source      = var.private_cidr
    source_type = "CIDR_BLOCK"
    protocol    = "all"
  }
}
