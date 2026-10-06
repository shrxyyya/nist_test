# Copyright IBM Corp. 2026

# ActiveMQ brokers should use active/standby deployment mode

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "mq-active-deployment-mode-enforcement-level" {
    type = string
    default = "advisory"
}

resource_policy "aws_mq_broker" "mq_active_deployment_mode" {
  filter = core::try(attrs.engine_type, null) == "ActiveMQ"

  locals {
    mode_raw        = core::try(attrs.deployment_mode, null)
    deployment_mode = local.mode_raw != null ? local.mode_raw : "SINGLE_INSTANCE"
    is_compliant    = local.deployment_mode == "ACTIVE_STANDBY_MULTI_AZ" || local.deployment_mode == "CLUSTER_MULTI_AZ"
  }

  enforcement_level = input.mq-active-deployment-mode-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Amazon MQ brokers should use ACTIVE_STANDBY_MULTI_AZ or CLUSTER_MULTI_AZ deployment mode for high availability."
  }
}
