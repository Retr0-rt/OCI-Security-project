output "bastion_id" {
  value       = oci_bastion_bastion.main_bastion.id
  description = "OCID of the OCI Bastion Service"
}

output "app_server_private_ip" {
  value       = oci_core_instance.app_server.private_ip
  description = "Private IP address of the App Server"
}

output "app_server_id" {
  value       = oci_core_instance.app_server.id
  description = "OCID of the App Server"
}

output "session_command" {
  value = oci_bastion_session.app_vm_ssh.ssh_metadata
}
