# Copyright IBM Corp. 2026

# Neptune clusters should be deployed in multiple availability zones

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "neptune-cluster-should-be-deployed-in-multi-az-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_neptune_cluster" "neptune_cluster_should_be_deployed_in_multi_az" {
  locals {
    azs_raw = core::try(attrs.availability_zones, null)
    azs     = local.azs_raw != null ? local.azs_raw : []
  }

  enforcement_level = input.neptune-cluster-should-be-deployed-in-multi-az-enforcement-level
  enforce {
    condition     = core::length(local.azs) >= 2
    error_message = "Attribute 'availability_zones' must be greater than or equal to 2 for 'aws_neptune_cluster' resources"
  }
}
