# Copyright IBM Corp. 2026

policytest {
  targets = ["s3-bucket-should-use-cross-region-replication.policy.hcl"]
}

# PASS: bucket referenced by an enabled replication configuration with destination
resource "aws_s3_bucket" "pass_replicated" {
  attrs = {
    id     = "replicated-bucket"
    bucket = "replicated-bucket"
  }
}

resource "aws_s3_bucket_replication_configuration" "repl_for_replicated" {
  skip = true
  attrs = {
    bucket = "replicated-bucket"
    role   = "arn:aws:iam::123456789012:role/replication"
    rule = [{
      id     = "replicate-all"
      status = "Enabled"
      destination = [{
        bucket = "arn:aws:s3:::destination-bucket"
      }]
    }]
  }
}

# FAIL: no replication configuration for this bucket
resource "aws_s3_bucket" "fail_no_replication" {
  expect_failure = true
  attrs = {
    id     = "unreplicated-bucket"
    bucket = "unreplicated-bucket"
  }
}

# FAIL: replication configuration exists but status is "Disabled"
resource "aws_s3_bucket" "fail_disabled_rule" {
  expect_failure = true
  attrs = {
    id     = "disabled-replication-bucket"
    bucket = "disabled-replication-bucket"
  }
}

resource "aws_s3_bucket_replication_configuration" "repl_disabled" {
  skip = true
  attrs = {
    bucket = "disabled-replication-bucket"
    role   = "arn:aws:iam::123456789012:role/replication"
    rule = [{
      id     = "disabled-rule"
      status = "Disabled"
      destination = [{
        bucket = "arn:aws:s3:::destination-bucket"
      }]
    }]
  }
}

# FAIL: replication configuration has empty rules
resource "aws_s3_bucket" "fail_empty_rules" {
  expect_failure = true
  attrs = {
    id     = "empty-rules-bucket"
    bucket = "empty-rules-bucket"
  }
}

resource "aws_s3_bucket_replication_configuration" "repl_empty_rules" {
  skip = true
  attrs = {
    bucket = "empty-rules-bucket"
    role   = "arn:aws:iam::123456789012:role/replication"
    rule   = []
  }
}

# FAIL: only a replication configuration for another bucket exists
resource "aws_s3_bucket_replication_configuration" "repl_for_unrelated" {
  skip = true
  attrs = {
    bucket = "unrelated-bucket"
    role   = "arn:aws:iam::123456789012:role/replication"
    rule = [{
      id     = "replicate-all"
      status = "Enabled"
      destination = [{
        bucket = "arn:aws:s3:::destination-bucket"
      }]
    }]
  }
}

resource "aws_s3_bucket" "fail_other_bucket_replicated" {
  expect_failure = true
  attrs = {
    id     = "other-bucket"
    bucket = "other-bucket"
  }
}

# FAIL: id explicitly null
resource "aws_s3_bucket" "fail_null_id" {
  expect_failure = true
  attrs = {
    id     = null
    bucket = "null-id-bucket"
  }
}

# FAIL: id attribute missing
resource "aws_s3_bucket" "fail_missing_id" {
  expect_failure = true
  attrs = {
    bucket = "missing-id-bucket"
  }
}
