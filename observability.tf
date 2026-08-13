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

  is_free_tier = true
}

data "oci_log_analytics_namespace" "stage26" {
  namespace = var.log_analytics_namespace
}

resource "oci_log_analytics_log_analytics_log_group" "security_analytics" {
  compartment_id = var.compartment_id
  namespace      = data.oci_log_analytics_namespace.stage26.namespace

  display_name = "Stage26-Security-Analytics"

  description = "Centralized security analytics for Stage26"
}

resource "oci_sch_service_connector" "stage26_logs_to_analytics" {
  compartment_id = var.compartment_id

  display_name = "SC_Stage26_Logs_To_Analytics"
  description  = "Centralizes Stage26 Audit and OCI Logging data into Log Analytics"

  source {
    kind = "logging"

    # OCI Audit logs
    log_sources {
      compartment_id = var.tenancy_id
      log_group_id   = "_Audit"
    }

    log_sources {
      compartment_id = var.compartment_id
      log_group_id   = oci_logging_log_group.security_log_group.id
    }
  }

  target {
    kind         = "loggingAnalytics"
    log_group_id = oci_log_analytics_log_analytics_log_group.security_analytics.id
  }
}

# this part is a simple policy to let the service connector to manage logging data

resource "oci_identity_policy" "stage26_logging_analytics_connector" {
  compartment_id = var.tenancy_id

  name = "Stage26-Logging-Analytics-Connector"
  description = "Permissions for Stage26 Service Connector to read OCI Logging/Audit and write to Log Analytics"

  statements = [
    "Allow any-user to read logging-family in tenancy where all {request.principal.type = 'serviceconnector', request.principal.compartment.id = '${var.compartment_id}'}",

    "Allow any-user to read audit-events in tenancy where all {request.principal.type = 'serviceconnector', request.principal.compartment.id = '${var.compartment_id}'}",

    "Allow any-user to use loganalytics-log-group in compartment id ${var.compartment_id} where all {request.principal.type = 'serviceconnector', target.loganalytics-log-group.id = '${oci_log_analytics_log_analytics_log_group.security_analytics.id}', request.principal.compartment.id = '${var.compartment_id}'}"
  ]
}