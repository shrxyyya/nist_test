# Copyright IBM Corp. 2026

# Network Firewall should be deployed across multiple availability zones

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "network-firewall-should-be-deployed-across-multiple-azs-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_networkfirewall_firewall" "network_firewall_multiple_azs" {
  locals {
    az_mapping_raw = core::try(attrs.availability_zone_mapping, null)
    az_mapping     = local.az_mapping_raw != null ? local.az_mapping_raw : []
  }

  enforcement_level = input.network-firewall-should-be-deployed-across-multiple-azs-enforcement-level
  enforce {
    condition     = core::length(local.az_mapping) >= 2
    error_message = "Resource 'aws_networkfirewall_firewall' should be deployed across multiple availability zones (at least 2 availability_zone_mapping entries)."
  }
}
