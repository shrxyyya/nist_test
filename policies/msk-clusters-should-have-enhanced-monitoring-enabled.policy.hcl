# Copyright IBM Corp. 2026

# MSK clusters should have enhanced monitoring enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "msk-clusters-should-have-enhanced-monitoring-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_msk_cluster" "enhanced_monitoring_enabled" {
  locals {
    monitoring_raw = core::try(attrs.enhanced_monitoring, null)
    monitoring     = local.monitoring_raw != null ? local.monitoring_raw : "DEFAULT"
    is_compliant   = local.monitoring != "DEFAULT" && local.monitoring != "PER_BROKER"
  }

  enforcement_level = input.msk-clusters-should-have-enhanced-monitoring-enabled-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Attribute 'enhanced_monitoring' should not be set to 'DEFAULT' or 'PER_BROKER' in the monitoring configuration for AWS MSK Cluster. Set it to 'PER_TOPIC_PER_BROKER' or 'PER_TOPIC_PER_PARTITION'."
  }
}
