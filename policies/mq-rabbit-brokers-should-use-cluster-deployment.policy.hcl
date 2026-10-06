# Copyright IBM Corp. 2026

# RabbitMQ brokers should use cluster deployment mode

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "mq-rabbit-brokers-should-use-cluster-deployment-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_mq_broker" "mq_rabbit_brokers_should_use_cluster_deployment" {
  filter = core::try(attrs.engine_type, null) == "RabbitMQ"

  locals {
    deployment_mode_raw = core::try(attrs.deployment_mode, null)
    deployment_mode     = local.deployment_mode_raw != null ? local.deployment_mode_raw : "SINGLE_INSTANCE"
  }

  enforcement_level = input.mq-rabbit-brokers-should-use-cluster-deployment-enforcement-level
  enforce {
    condition     = local.deployment_mode == "CLUSTER_MULTI_AZ"
    error_message = "Attribute 'deployment_mode' should be 'CLUSTER_MULTI_AZ' for AWS RabbitMQ Broker"
  }
}
