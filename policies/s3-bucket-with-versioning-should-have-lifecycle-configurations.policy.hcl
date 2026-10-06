# Copyright IBM Corp. 2026

# S3 buckets with versioning enabled should have lifecycle configurations

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "s3-bucket-with-versioning-should-have-lifecycle-configurations-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_s3_bucket" "versioned_bucket_has_lifecycle_configuration" {
  locals {
    versioning_resources = core::getresources("aws_s3_bucket_versioning", {
      bucket = attrs.id
    })
    lifecycle_resources = core::getresources("aws_s3_bucket_lifecycle_configuration", {
      bucket = attrs.id
    })

    # Versioning is enabled when any associated versioning resource has status "Enabled"
    enabled_versioning = core::length(local.versioning_resources) > 0 ? [for v in local.versioning_resources : v
      if core::try(v.versioning_configuration[0].status, "") == "Enabled"
    ] : []
    has_versioning_enabled = core::length(local.enabled_versioning) > 0
    has_lifecycle          = core::length(local.lifecycle_resources) > 0
  }

  # Only buckets with versioning enabled are in scope
  filter = local.has_versioning_enabled

  enforcement_level = input.s3-bucket-with-versioning-should-have-lifecycle-configurations-enforcement-level
  enforce {
    condition     = local.has_lifecycle
    error_message = "S3 Buckets with versioning should have lifecycle configurations. Add an aws_s3_bucket_lifecycle_configuration resource for this bucket."
  }
}
