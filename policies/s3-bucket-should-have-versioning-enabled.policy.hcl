# Copyright IBM Corp. 2026

# S3 buckets should have versioning enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "s3-bucket-should-have-versioning-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_s3_bucket" "s3_bucket_should_have_versioning_enabled" {
  locals {
    versioning_resources = core::getresources("aws_s3_bucket_versioning", {
      bucket = attrs.id
    })
    enabled_versioning = [
      for v in local.versioning_resources : v
      if core::try(v.versioning_configuration[0].status, "") == "Enabled"
    ]
    versioning_enabled = core::length(local.enabled_versioning) > 0
  }

  enforcement_level = input.s3-bucket-should-have-versioning-enabled-enforcement-level
  enforce {
    condition     = local.versioning_enabled
    error_message = "S3 Buckets should have versioning enabled. Add an aws_s3_bucket_versioning resource for this bucket with versioning_configuration { status = \"Enabled\" }."
  }
}
