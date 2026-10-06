# Copyright IBM Corp. 2026

policytest {
  targets = ["eventbridge-global-endpoints-should-have-event-replication-enabled.policy.hcl"]
}

resource "aws_cloudwatch_event_endpoint" "pass_enabled" {
  attrs = {
    name     = "ep"
    role_arn = "arn:aws:iam::123456789012:role/replication"
    replication_config = [{
      state = "ENABLED"
    }]
  }
}

resource "aws_cloudwatch_event_endpoint" "fail_disabled" {
  expect_failure = true
  attrs = {
    name = "ep"
    replication_config = [{
      state = "DISABLED"
    }]
  }
}

resource "aws_cloudwatch_event_endpoint" "fail_no_replication_config" {
  expect_failure = true
  attrs = {
    name = "ep"
  }
}

resource "aws_cloudwatch_event_endpoint" "fail_empty_replication_config" {
  expect_failure = true
  attrs = {
    name               = "ep"
    replication_config = []
  }
}

resource "aws_cloudwatch_event_endpoint" "fail_null_state" {
  expect_failure = true
  attrs = {
    name = "ep"
    replication_config = [{
      state = null
    }]
  }
}

resource "aws_cloudwatch_event_endpoint" "fail_lowercase_state" {
  expect_failure = true
  attrs = {
    name = "ep"
    replication_config = [{
      state = "enabled"
    }]
  }
}

