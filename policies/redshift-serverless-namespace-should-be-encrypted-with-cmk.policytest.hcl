# Copyright IBM Corp. 2026

policytest {
  targets = ["redshift-serverless-namespace-should-be-encrypted-with-cmk.policy.hcl"]
}

resource "aws_redshiftserverless_namespace" "pass_kms_arn" {
  attrs = {
    namespace_name = "pass-arn"
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  }
}

resource "aws_redshiftserverless_namespace" "pass_kms_key_id_string" {
  attrs = {
    namespace_name = "pass-id"
    kms_key_id     = "12345678-1234-1234-1234-123456789012"
  }
}

resource "aws_redshiftserverless_namespace" "fail_missing_kms" {
  expect_failure = true
  attrs = {
    namespace_name = "fail-missing"
  }
}

resource "aws_redshiftserverless_namespace" "fail_null_kms" {
  expect_failure = true
  attrs = {
    namespace_name = "fail-null"
    kms_key_id     = null
  }
}

resource "aws_redshiftserverless_namespace" "fail_empty_kms" {
  expect_failure = true
  attrs = {
    namespace_name = "fail-empty"
    kms_key_id     = ""
  }
}

