# Copyright IBM Corp. 2026

policytest {
  targets = ["sns-topic-should-be-encrypted-at-rest.policy.hcl"]
}

# PASS: custom KMS key
resource "aws_sns_topic" "pass_custom_kms_key" {
  attrs = {
    name              = "topic-custom"
    kms_master_key_id = "arn:aws:kms:us-east-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
  }
}

# PASS: AWS managed key
resource "aws_sns_topic" "pass_aws_managed_key" {
  attrs = {
    name              = "topic-managed"
    kms_master_key_id = "alias/aws/sns"
  }
}

# FAIL: attribute omitted
resource "aws_sns_topic" "fail_missing_kms_key" {
  expect_failure = true
  attrs = {
    name = "topic-missing"
  }
}

# FAIL: explicit null (policy treats null as non-compliant)
resource "aws_sns_topic" "fail_null_kms_key" {
  expect_failure = true
  attrs = {
    name              = "topic-null"
    kms_master_key_id = null
  }
}

# FAIL: empty string
resource "aws_sns_topic" "fail_empty_kms_key" {
  expect_failure = true
  attrs = {
    name              = "topic-empty"
    kms_master_key_id = ""
  }
}

