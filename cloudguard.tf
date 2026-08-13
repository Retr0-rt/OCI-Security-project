# notifications
resource "oci_ons_notification_topic" "cloud_guard_topic" {
  compartment_id = var.compartment_id
  name           = "Cloud_Guard-Alerts"
  description    = "Notification topic for cloud guard "
}

resource "oci_ons_subscription" "email_subscription" {
  compartment_id = var.compartment_id
  topic_id       = oci_ons_notification_topic.cloud_guard_topic.id
  protocol       = "EMAIL"
  endpoint       = var.alert_email_address
}

# OCI events rules
resource "oci_events_rule" "cloud_guard_event_rule" {
  compartment_id = var.compartment_id
  display_name   = "Rule_CG_events"
  is_enabled     = true
  description    = "Route CG problems and automated remediations to ONS notification topic"

  condition = jsonencode({
    "eventType" : [
      "com.oraclecloud.cloudguard.problemdetected",
      "com.oraclecloud.cloudguard.remediationexecuted"
    ]
  })

  actions {
    action {
      action_type = "ONS"
      is_enabled  = true
      topic_id    = oci_ons_notification_topic.cloud_guard_topic.id
    }
  }
}

# Cloud guard target and recipe cloning 
data "oci_cloud_guard_detector_recipe" "oracle_configuration" {
  detector_recipe_id = var.configuration_detector_recipe_id
}

data "oci_cloud_guard_detector_recipe" "oracle_threat" {
  detector_recipe_id = var.threat_detector_recipe_id
}

data "oci_cloud_guard_responder_recipe" "oracle_responder" {
  responder_recipe_id = var.responder_recipe_id
}

resource "oci_cloud_guard_detector_recipe" "custom_config_detector" {
  compartment_id            = var.compartment_id
  display_name              = "Custom_Config_Detector_Stage26"
  source_detector_recipe_id = data.oci_cloud_guard_detector_recipe.oracle_configuration.id

  # Custom Rules Configuration

  # IAM PRIVILEGE CONTROL
  ########################
  detector_rules {
    detector_rule_id = "POLICY_GIVES_MANY_PRIVILEGES"

    details {
      is_enabled = true
      risk_level = "HIGH"
    }
  }

  detector_rules {
    detector_rule_id = "POLICY_TENANCY_ADMIN_GROUP_PRIVILEGES"

    details {
      is_enabled = true
      risk_level = "HIGH"
    }
  }

  # NETWORK SECURITY
  ###################

  # Keep Oracle's critical public-source detection.
  # This explicitly addresses 0.0.0.0/0 exposure.
  detector_rules {
    detector_rule_id = "SECURITY_LISTS_OPEN_SOURCE"

    details {
      is_enabled = true
      risk_level = "CRITICAL"
    }
  }

  # DATABASE SECURITY
  #####################

  detector_rules {
    detector_rule_id = "DATABASE_PUBLICLY_ACCESSIBLE"

    details {
      is_enabled = true
      risk_level = "CRITICAL"
    }
  }

  detector_rules {
    detector_rule_id = "DATABASE_HAS_PUBLIC_IP"

    details {
      is_enabled = true
      risk_level = "CRITICAL"
    }
  }

  detector_rules {
    detector_rule_id = "DATABASE_HAS_NO_AUTO_BACKUP"

    details {
      is_enabled = true
      risk_level = "HIGH"
    }
  }

  # VULNERABILITY SCANNING
  ##########################

  detector_rules {
    detector_rule_id = "SCANNED_HOST_VULNERABILITY"

    details {
      is_enabled = true
      risk_level = "CRITICAL"

      configurations {
        config_key = "cveSeverityLevel"
        name       = "CVE Severity Level"
        data_type  = "string"
        value      = "HIGH"
      }
    }
  }

  detector_rules {
    detector_rule_id = "SCANNED_CONTAINER_IMAGE_VULNERABILITY"

    details {
      is_enabled = true
      risk_level = "CRITICAL"

      configurations {
        config_key = "cveSeverityLevel"
        name       = "CVE Severity Level"
        data_type  = "string"
        value      = "HIGH"
      }
    }
  }
}

# Clone Default Responder Recipe for Automated Actions & Alerts
resource "oci_cloud_guard_responder_recipe" "custom_responder" {
  compartment_id             = var.compartment_id
  display_name               = "Custom_Responder_Recipe_Stage26"
  source_responder_recipe_id = data.oci_cloud_guard_responder_recipe.oracle_responder.id

  # Cloud Guard problem -> OCI Events
  responder_rules {
    responder_rule_id = "EVENT"

    details {
      is_enabled = true
    }
  }

  # AUTO-REMEDIATION
  #######################

  # Public bucket -> make private
  # in the initial Stage26 deployment.
  responder_rules {
    responder_rule_id = "MAKE_BUCKET_PRIVATE"

    details {
      is_enabled = true
    }
  }

  # MANUAL REMEDIATION
  #######################3

  # Public Compute IP
  responder_rules {
    responder_rule_id = "DELETE_PUBLIC_IP"

    details {
      is_enabled = true
    }
  }

  # Overly permissive IAM policy
  responder_rules {
    responder_rule_id = "DELETE_IAM_POLICY"

    details {
      is_enabled = true
    }
  }

  # Disable compromised / problematic IAM user
  responder_rules {
    responder_rule_id = "DISABLE_IAM_USER"

    details {
      is_enabled = true
    }
  }

  # Internet Gateway removal
  responder_rules {
    responder_rule_id = "DELETE_INTERNET_GATEWAY"

    details {
      is_enabled = true
    }
  }

  # Enable database automatic backup
  responder_rules {
    responder_rule_id = "ENABLE_DB_BACKUP"

    details {
      is_enabled = true
    }
  }

  # Rotate Vault key
  responder_rules {
    responder_rule_id = "ROTATE_VAULT_KEY"

    details {
      is_enabled = true
    }
  }

  # Stop instance
  responder_rules {
    responder_rule_id = "STOP_INSTANCE"

    details {
      is_enabled = true
    }
  }

  # Terminate instance
  #
  # Kept available but MANUAL only because this is destructive.
  responder_rules {
    responder_rule_id = "TERMINATE_INSTANCE"

    details {
      is_enabled = true
    }
  }
}

#######################
# Setting up the target

resource "oci_cloud_guard_target" "stage_target" {
  compartment_id       = var.compartment_id
  display_name         = "Target_Stage26_Compartment"
  target_resource_id   = var.compartment_id
  target_resource_type = "COMPARTMENT"

  target_detector_recipes {
    detector_recipe_id = oci_cloud_guard_detector_recipe.custom_config_detector.id
  }

  target_detector_recipes {
    detector_recipe_id = data.oci_cloud_guard_detector_recipe.oracle_threat.id
  }

  target_responder_recipes {
    responder_recipe_id = oci_cloud_guard_responder_recipe.custom_responder.id
  }
}

