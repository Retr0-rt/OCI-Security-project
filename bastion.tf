resource "oci_bastion_bastion" "main_bastion" {
  compartment_id = var.compartment_id
  bastion_type   = "STANDARD"
  name           = "Bastion_Service_St26"


  target_subnet_id             = oci_core_subnet.public_subnet.id
  client_cidr_block_allow_list = ["0.0.0.0/0"]
  max_session_ttl_in_seconds   = 10800
}

resource "oci_bastion_session" "app_vm_ssh" {
  bastion_id = oci_bastion_bastion.main_bastion.id

  key_details {
    public_key_content = var.ssh_public_key
  }

  display_name           = "ManagedSSH-AppVM"
  key_type               = "PUB"
  session_ttl_in_seconds = 10800

  target_resource_details {
    session_type                               = "MANAGED_SSH"
    target_resource_id                         = oci_core_instance.app_server.id
    target_resource_operating_system_user_name = "opc"
  }
}
