# the load balancer nsg configuration
#####################################
resource "oci_core_network_security_group" "lb_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  display_name   = "NSG_LB_St26"
}

resource "oci_core_network_security_group_security_rule" "lb_ingress_https" {
  network_security_group_id = oci_core_network_security_group.lb_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "CIDR_BLOCK"
  source                    = "0.0.0.0/0"
  stateless                 = false
  description               = "accept traffic from the internet on port 443"

  tcp_options {
    destination_port_range {
      min = var.web_port
      max = var.web_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "lb_egress_app_server" {
  network_security_group_id = oci_core_network_security_group.lb_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination_type          = "NETWORK_SECURITY_GROUP"
  destination               = oci_core_network_security_group.app_nsg.id
  stateless                 = false
  description               = "Allow outbound traffic only towards the app in the private subnet"

  tcp_options {
    destination_port_range {
      min = var.web_port
      max = var.web_port
    }
  }
}

# the application server VM NSG
###############################

resource "oci_core_network_security_group" "app_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  display_name   = "NSG_App_St26"
}

resource "oci_core_network_security_group_security_rule" "ingress_ssh" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id

  direction = "INGRESS"
  protocol  = "6"

  source_type = "CIDR_BLOCK"
  source      = "0.0.0.0/0"
  description = "allow access to port 22 from bastion"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_ingress_from_lb" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.lb_nsg.id
  stateless                 = false
  description               = "allow https access from the load balancer"

  tcp_options {
    destination_port_range {
      min = var.web_port
      max = var.web_port
    }
  }
}

resource "oci_core_network_security_group_security_rule" "app_egress_to_db" {
  network_security_group_id = oci_core_network_security_group.app_nsg.id
  direction                 = "EGRESS"
  protocol                  = "6"
  destination_type          = "NETWORK_SECURITY_GROUP"
  destination               = oci_core_network_security_group.db_nsg.id
  stateless                 = false
  description               = "allow outbound traffic toward the database from the app server"

  tcp_options {
    destination_port_range {
      min = var.db_port
      max = var.db_port
    }
  }
}

# The database VM nsg configuration
resource "oci_core_network_security_group" "db_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id
  display_name   = "NSG_DB_St26"
}

resource "oci_core_network_security_group_security_rule" "ingress_ssh_to_db" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id

  direction = "INGRESS"
  protocol  = "6"

  source_type = "CIDR_BLOCK"
  source      = "0.0.0.0/0"
  description = "allow access to port 22 from bastion to database"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "ingress_app_to_db" {
  network_security_group_id = oci_core_network_security_group.db_nsg.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source_type               = "NETWORK_SECURITY_GROUP"
  source                    = oci_core_network_security_group.app_nsg.id
  stateless                 = false
  description               = "isolate the database by only allowing only traffic from the app server on port 1521"

  tcp_options {
    destination_port_range {
      min = var.db_port
      max = var.db_port
    }
  }
}


### an nsg misscofiguration to test cloud guard rules

resource "oci_core_network_security_group" "cloud_guard_test_nsg" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.secure_vcn.id

  display_name = "NSG_CloudGuard_Test"
}

resource "oci_core_network_security_group_security_rule" "cloud_guard_test_rule" {
  network_security_group_id = oci_core_network_security_group.cloud_guard_test_nsg.id

  direction   = "INGRESS"
  protocol    = "6"
  source      = "0.0.0.0/0"
  source_type = "CIDR_BLOCK"

  tcp_options {
    destination_port_range {
      min = 3306
      max = 3306
    }
  }
}