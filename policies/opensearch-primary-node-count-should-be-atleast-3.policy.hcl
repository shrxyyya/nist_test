# Copyright IBM Corp. 2026

# OpenSearch domains should have at least 3 dedicated primary nodes

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "opensearch-primary-node-count-should-be-atleast-3-enforcement-level" {
  type    = string
  default = "advisory"
}

input "dedicated_master_count_param" {
  type    = number
  default = 3
}

resource_policy "aws_opensearch_domain" "opensearch_primary_node_count_should_be_atleast_3" {
  locals {
    cluster_config_raw = core::try(attrs.cluster_config, null)
    cluster_config     = local.cluster_config_raw != null ? local.cluster_config_raw : []
    has_config         = core::length(local.cluster_config) > 0
    master_count       = local.has_config ? core::try(local.cluster_config[0].dedicated_master_count, null) : null
    master_enabled     = local.has_config ? core::try(local.cluster_config[0].dedicated_master_enabled, null) : null
    is_compliant       = local.master_count != null && local.master_enabled != null && local.master_count >= input.dedicated_master_count_param && local.master_enabled == true
  }

  filter = local.has_config && local.master_count != null && local.master_enabled != null

  enforcement_level = input.opensearch-primary-node-count-should-be-atleast-3-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Attribute 'dedicated_master_enabled' should be true and 'dedicated_master_count' in 'cluster_config' should atleast 3 for AWS OpenSearch Domain."
  }
}
