# Copyright IBM Corp. 2026

# Redshift Serverless namespaces should be encrypted with a customer-managed KMS key

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "redshift-serverless-namespace-should-be-encrypted-with-cmk-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_redshiftserverless_namespace" "redshift_serverless_namespace_should_be_encrypted_with_cmk" {
  locals {
    kms_key_id_raw = core::try(attrs.kms_key_id, null)
    has_kms_key    = local.kms_key_id_raw != null && local.kms_key_id_raw != ""
  }

  enforcement_level = input.redshift-serverless-namespace-should-be-encrypted-with-cmk-enforcement-level
  enforce {
    condition     = local.has_kms_key
    error_message = "Attribute 'kms_key_id' must be present for 'aws_redshiftserverless_namespace' resources"
  }
}
