# Copyright IBM Corp. 2026

policytest {
  targets = ["msk-clusters-should-have-enhanced-monitoring-enabled.policy.hcl"]
}

resource "aws_msk_cluster" "pass_per_topic_per_broker" {
  attrs = {
    cluster_name           = "pass-1"
    kafka_version          = "3.5.1"
    number_of_broker_nodes = 3
    enhanced_monitoring    = "PER_TOPIC_PER_BROKER"
  }
}

resource "aws_msk_cluster" "pass_per_topic_per_partition" {
  attrs = {
    cluster_name           = "pass-2"
    kafka_version          = "3.5.1"
    number_of_broker_nodes = 3
    enhanced_monitoring    = "PER_TOPIC_PER_PARTITION"
  }
}

resource "aws_msk_cluster" "fail_default" {
  expect_failure = true
  attrs = {
    cluster_name           = "fail-default"
    kafka_version          = "3.5.1"
    number_of_broker_nodes = 3
    enhanced_monitoring    = "DEFAULT"
  }
}

resource "aws_msk_cluster" "fail_per_broker" {
  expect_failure = true
  attrs = {
    cluster_name           = "fail-per-broker"
    kafka_version          = "3.5.1"
    number_of_broker_nodes = 3
    enhanced_monitoring    = "PER_BROKER"
  }
}

# Attribute omitted: treated as DEFAULT -> violation
resource "aws_msk_cluster" "fail_missing_enhanced_monitoring" {
  expect_failure = true
  attrs = {
    cluster_name           = "fail-missing"
    kafka_version          = "3.5.1"
    number_of_broker_nodes = 3
  }
}

# Explicit null: normalized to DEFAULT -> violation
resource "aws_msk_cluster" "fail_null_enhanced_monitoring" {
  expect_failure = true
  attrs = {
    cluster_name           = "fail-null"
    kafka_version          = "3.5.1"
    number_of_broker_nodes = 3
    enhanced_monitoring    = null
  }
}

