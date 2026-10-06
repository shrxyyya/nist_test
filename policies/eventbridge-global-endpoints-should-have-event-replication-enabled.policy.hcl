# Copyright IBM Corp. 2026

# EventBridge global endpoints should have event replication enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "eventbridge-global-endpoints-should-have-event-replication-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_cloudwatch_event_endpoint" "event_replication_enabled" {
  locals {
    replication_config_raw = core::try(attrs.replication_config, null)
    replication_config     = local.replication_config_raw != null ? local.replication_config_raw : []
    has_config             = core::length(local.replication_config) > 0
    state_raw              = local.has_config ? core::try(local.replication_config[0].state, null) : null
    is_enabled             = local.state_raw == "ENABLED"
  }

  enforcement_level = input.eventbridge-global-endpoints-should-have-event-replication-enabled-enforcement-level
  enforce {
    condition     = local.is_enabled
    error_message = "EventBridge Global Endpoints should have event replication enabled. Set 'replication_config.state' to 'ENABLED'."
  }
}
