# Copyright IBM Corp. 2026

policytest {
  targets = ["s3-bucket-with-versioning-should-have-lifecycle-configurations.policy.hcl"]
}

# ---- Companion resources (lookup-only, not evaluated directly) ----

resource "aws_s3_bucket_versioning" "ver_compliant" {
  skip = true
  attrs = {
    bucket = "compliant-bucket"
    versioning_configuration = [{
      status = "Enabled"
    }]
  }
}

resource "aws_s3_bucket_versioning" "ver_noncompliant" {
  skip = true
  attrs = {
    bucket = "noncompliant-bucket"
    versioning_configuration = [{
      status = "Enabled"
    }]
  }
}

resource "aws_s3_bucket_versioning" "ver_suspended" {
  skip = true
  attrs = {
    bucket = "suspended-bucket"
    versioning_configuration = [{
      status = "Suspended"
    }]
  }
}

resource "aws_s3_bucket_versioning" "ver_other_lifecycle" {
  skip = true
  attrs = {
    bucket = "other-lifecycle-bucket"
    versioning_configuration = [{
      status = "Enabled"
    }]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lc_compliant" {
  skip = true
  attrs = {
    bucket = "compliant-bucket"
    rule = [{
      id     = "expire"
      status = "Enabled"
    }]
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "lc_unrelated" {
  skip = true
  attrs = {
    bucket = "some-unrelated-bucket"
    rule = [{
      id     = "expire"
      status = "Enabled"
    }]
  }
}

# ---- Buckets under test ----

# PASS: versioning Enabled and lifecycle configuration present
resource "aws_s3_bucket" "pass_versioned_with_lifecycle" {
  attrs = {
    id     = "compliant-bucket"
    bucket = "compliant-bucket"
  }
}

# PASS: versioning Suspended, out of scope
resource "aws_s3_bucket" "pass_versioning_suspended_no_lifecycle" {
  attrs = {
    id     = "suspended-bucket"
    bucket = "suspended-bucket"
  }
}

# PASS: no versioning resource at all, out of scope
resource "aws_s3_bucket" "pass_no_versioning_no_lifecycle" {
  attrs = {
    id     = "unversioned-bucket"
    bucket = "unversioned-bucket"
  }
}

# FAIL: versioning Enabled but no lifecycle configuration
resource "aws_s3_bucket" "fail_versioned_without_lifecycle" {
  expect_failure = true
  attrs = {
    id     = "noncompliant-bucket"
    bucket = "noncompliant-bucket"
  }
}

# FAIL: versioning Enabled; only lifecycle configuration present belongs to another bucket
resource "aws_s3_bucket" "fail_versioned_lifecycle_for_other_bucket" {
  expect_failure = true
  attrs = {
    id     = "other-lifecycle-bucket"
    bucket = "other-lifecycle-bucket"
  }
}

