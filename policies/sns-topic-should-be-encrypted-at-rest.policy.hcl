# Copyright IBM Corp. 2026

# SNS topics should be encrypted at rest

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "sns-topic-should-be-encrypted-at-rest-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_sns_topic" "sns_topic_should_be_encrypted_at_rest" {
  locals {
    kms_key_raw = core::try(attrs.kms_master_key_id, null)
    has_kms_key = local.kms_key_raw != null && local.kms_key_raw != ""
  }

  enforcement_level = input.sns-topic-should-be-encrypted-at-rest-enforcement-level
  enforce {
    condition     = local.has_kms_key
    error_message = "Attribute 'kms_master_key_id' must be present for 'aws_sns_topic' resources"
  }
}
