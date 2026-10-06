# Copyright IBM Corp. 2026

policytest {
  targets = ["neptune-cluster-should-be-deployed-in-multi-az.policy.hcl"]
}

resource "aws_neptune_cluster" "pass_two_azs" {
  attrs = {
    cluster_identifier = "pass-two"
    availability_zones = ["us-east-1a", "us-east-1b"]
  }
}

resource "aws_neptune_cluster" "pass_three_azs" {
  attrs = {
    cluster_identifier = "pass-three"
    availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]
  }
}

resource "aws_neptune_cluster" "fail_one_az" {
  expect_failure = true
  attrs = {
    cluster_identifier = "fail-one"
    availability_zones = ["us-east-1a"]
  }
}

resource "aws_neptune_cluster" "fail_empty_azs" {
  expect_failure = true
  attrs = {
    cluster_identifier = "fail-empty"
    availability_zones = []
  }
}

# Missing attribute entirely
resource "aws_neptune_cluster" "fail_missing_azs" {
  expect_failure = true
  attrs = {
    cluster_identifier = "fail-missing"
  }
}

# Explicit null is normalized to empty list -> violation
resource "aws_neptune_cluster" "fail_null_azs" {
  expect_failure = true
  attrs = {
    cluster_identifier = "fail-null"
    availability_zones = null
  }
}

