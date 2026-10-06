# Copyright IBM Corp. 2026

# S3 buckets should use cross-region replication

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "s3-bucket-should-use-cross-region-replication-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_s3_bucket" "s3_bucket_should_use_cross_region_replication" {
  locals {
    bucket_id = core::try(attrs.id, null)
    replications = local.bucket_id != null ? core::getresources("aws_s3_bucket_replication_configuration", {
      bucket = attrs.id
    }) : []

    rules = core::flatten([
      for repl in local.replications : core::try(repl.rule, core::try(repl.attrs.rule, []))
    ])

    enabled_replication_rules = [
      for r in local.rules : r
      if core::try(r.status, "") == "Enabled" &&
         core::length(core::try(r.destination, [])) > 0 &&
         core::try(r.destination[0].bucket, null) != null
    ]

    has_active_replication = core::length(local.enabled_replication_rules) > 0
  }

  enforcement_level = input.s3-bucket-should-use-cross-region-replication-enforcement-level
  enforce {
    condition     = local.has_active_replication
    error_message = "S3 Buckets should have replication configuration with at least one enabled rule and destination configured."
  }
}
