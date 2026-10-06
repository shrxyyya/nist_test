# Copyright IBM Corp. 2026

policytest {
  targets = ["opensearch-primary-node-count-should-be-atleast-3.policy.hcl"]
}

resource "aws_opensearch_domain" "pass_enabled_count_3" {
  attrs = {
    domain_name = "d1"
    cluster_config = [{
      dedicated_master_enabled = true
      dedicated_master_count   = 3
    }]
  }
}

resource "aws_opensearch_domain" "pass_enabled_count_5" {
  attrs = {
    domain_name = "d2"
    cluster_config = [{
      dedicated_master_enabled = true
      dedicated_master_count   = 5
    }]
  }
}

resource "aws_opensearch_domain" "pass_no_cluster_config" {
  attrs = {
    domain_name = "d3"
  }
}

resource "aws_opensearch_domain" "pass_empty_cluster_config" {
  attrs = {
    domain_name    = "d4"
    cluster_config = []
  }
}

resource "aws_opensearch_domain" "pass_null_count" {
  attrs = {
    domain_name = "d5"
    cluster_config = [{
      dedicated_master_enabled = true
      dedicated_master_count   = null
    }]
  }
}

resource "aws_opensearch_domain" "pass_null_enabled" {
  attrs = {
    domain_name = "d6"
    cluster_config = [{
      dedicated_master_enabled = null
      dedicated_master_count   = 1
    }]
  }
}

resource "aws_opensearch_domain" "fail_enabled_count_2" {
  expect_failure = true
  attrs = {
    domain_name = "d7"
    cluster_config = [{
      dedicated_master_enabled = true
      dedicated_master_count   = 2
    }]
  }
}

resource "aws_opensearch_domain" "fail_enabled_count_1" {
  expect_failure = true
  attrs = {
    domain_name = "d8"
    cluster_config = [{
      dedicated_master_enabled = true
      dedicated_master_count   = 1
    }]
  }
}

resource "aws_opensearch_domain" "fail_disabled_count_3" {
  expect_failure = true
  attrs = {
    domain_name = "d9"
    cluster_config = [{
      dedicated_master_enabled = false
      dedicated_master_count   = 3
    }]
  }
}

resource "aws_opensearch_domain" "fail_disabled_count_1" {
  expect_failure = true
  attrs = {
    domain_name = "d10"
    cluster_config = [{
      dedicated_master_enabled = false
      dedicated_master_count   = 1
    }]
  }
}

