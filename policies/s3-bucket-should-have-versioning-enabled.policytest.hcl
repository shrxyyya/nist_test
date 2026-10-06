# Copyright IBM Corp. 2026

policytest {
  targets = ["s3-bucket-should-have-versioning-enabled.policy.hcl"]
}

# PASS: versioning Enabled
resource "aws_s3_bucket" "pass_enabled" {
  attrs = {
    id     = "bucket-enabled"
    bucket = "bucket-enabled"
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  skip = true
  attrs = {
    bucket = "bucket-enabled"
    versioning_configuration = [{
      status = "Enabled"
    }]
  }
}

# FAIL: no versioning resource
resource "aws_s3_bucket" "fail_no_versioning" {
  expect_failure = true
  attrs = {
    id     = "bucket-none"
    bucket = "bucket-none"
  }
}

# FAIL: Suspended
resource "aws_s3_bucket" "fail_suspended" {
  expect_failure = true
  attrs = {
    id     = "bucket-suspended"
    bucket = "bucket-suspended"
  }
}

resource "aws_s3_bucket_versioning" "suspended" {
  skip = true
  attrs = {
    bucket = "bucket-suspended"
    versioning_configuration = [{
      status = "Suspended"
    }]
  }
}

# FAIL: Disabled
resource "aws_s3_bucket" "fail_disabled" {
  expect_failure = true
  attrs = {
    id     = "bucket-disabled"
    bucket = "bucket-disabled"
  }
}

resource "aws_s3_bucket_versioning" "disabled" {
  skip = true
  attrs = {
    bucket = "bucket-disabled"
    versioning_configuration = [{
      status = "Disabled"
    }]
  }
}

# FAIL: versioning resource exists only for a different bucket
resource "aws_s3_bucket" "fail_other_bucket_versioned" {
  expect_failure = true
  attrs = {
    id     = "bucket-unlinked"
    bucket = "bucket-unlinked"
  }
}

# FAIL: versioning resource with missing versioning_configuration
resource "aws_s3_bucket" "fail_missing_config" {
  expect_failure = true
  attrs = {
    id     = "bucket-noconfig"
    bucket = "bucket-noconfig"
  }
}

resource "aws_s3_bucket_versioning" "noconfig" {
  skip = true
  attrs = {
    bucket = "bucket-noconfig"
  }
}

