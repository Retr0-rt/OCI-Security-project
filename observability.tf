resource "oci_logging_log_group" "security_log_group" {
  compartment_id = var.compartment_id
  display_name   = "LogGroup_St26"
  description    = "Centralized log group for Security Lab telemetry"
}

# Captures traffic entering the Bastion / Public boundary
resource "oci_logging_log" "public_subnet_flow_log" {
  display_name = "FlowLog_Public_Subnet_Stage26"
  log_group_id = oci_logging_log_group.security_log_group.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"
      resource    = oci_core_subnet.public_subnet.id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_id
  }
  is_enabled = true
}

# Captures traffic within the Private boundary (App VM & Database)
resource "oci_logging_log" "private_subnet_flow_log" {
  display_name = "FlowLog_Private_Subnet_Stage26"
  log_group_id = oci_logging_log_group.security_log_group.id
  log_type     = "SERVICE"

  configuration {
    source {
      category    = "all"
      resource    = oci_core_subnet.private_subnet.id
      service     = "flowlogs"
      source_type = "OCISERVICE"
    }
    compartment_id = var.compartment_id
  }
  is_enabled = true
}

# Captures detailed application traces and performance metrics
resource "oci_apm_apm_domain" "stage26_apm_domain" {
  compartment_id = var.compartment_id
  display_name   = "APM_Domain_St26"
  description    = "Always Free APM domain for tracing Python app performance"
  
  is_free_tier   = true 
}