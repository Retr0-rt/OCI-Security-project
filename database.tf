resource "oci_core_instance" "db_vm" {
    availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
    compartment_id = var.compartment_id
    display_name = "VM_Database_St26"
    shape = "VM.Standard.A1.Flex"

    shape_config {
        ocpus = 1
        memory_in_gbs = 2
    }
    create_vnic_details {
        subnet_id = oci_core_subnet.private_subnet.id
        display_name = "DB_VM_VNIC"
        assign_public_ip = false
        nsg_ids = [oci_core_network_security_group.db_nsg.id]
    }

    source_details {
        source_type = "image"
        source_id = data.oci_core_images.ol8.images[0].id
    }

    metadata = {
        ssh_authorized_keys = var.ssh_public_key
        user_data = base64encode(file("${path.module}\\scripts\\install_oracle_db.sh"))
    }
}