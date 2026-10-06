# Copyright IBM Corp. 2026

policytest {
  targets = ["s3-bucket-should-have-event-notifications-enabled.policy.hcl"]
}

# PASS: bucket referenced by a notification with a topic block
resource "aws_s3_bucket" "pass_with_topic_notification" {
  attrs = {
    id     = "bucket-pass"
    bucket = "bucket-pass"
  }
}

resource "aws_s3_bucket_notification" "pass_topic" {
  skip = true
  attrs = {
    bucket = "bucket-pass"
    topic = [{
      topic_arn = "arn:aws:sns:us-east-1:123456789012:example-topic"
      events    = ["s3:ObjectCreated:*"]
    }]
  }
}

# FAIL: no notification at all
resource "aws_s3_bucket" "fail_no_notification" {
  expect_failure = true
  attrs = {
    id     = "bucket-none"
    bucket = "bucket-none"
  }
}

# FAIL: notification has only a queue block (no topic)
resource "aws_s3_bucket" "fail_queue_only" {
  expect_failure = true
  attrs = {
    id     = "bucket-queue"
    bucket = "bucket-queue"
  }
}

resource "aws_s3_bucket_notification" "queue_only" {
  skip = true
  attrs = {
    bucket = "bucket-queue"
    queue = [{
      queue_arn = "arn:aws:sqs:us-east-1:123456789012:example-queue"
      events    = ["s3:ObjectCreated:*"]
    }]
  }
}

# FAIL: topic list is empty, eventbridge only
resource "aws_s3_bucket" "fail_empty_topic" {
  expect_failure = true
  attrs = {
    id     = "bucket-empty-topic"
    bucket = "bucket-empty-topic"
  }
}

resource "aws_s3_bucket_notification" "empty_topic" {
  skip = true
  attrs = {
    bucket      = "bucket-empty-topic"
    eventbridge = true
    topic       = []
  }
}

# FAIL: topic explicitly null
resource "aws_s3_bucket" "fail_null_topic" {
  expect_failure = true
  attrs = {
    id     = "bucket-null-topic"
    bucket = "bucket-null-topic"
  }
}

resource "aws_s3_bucket_notification" "null_topic" {
  skip = true
  attrs = {
    bucket = "bucket-null-topic"
    topic  = null
  }
}

# FAIL: only a notification for a different bucket exists (see bucket-pass / others)
resource "aws_s3_bucket" "fail_other_bucket_notification" {
  expect_failure = true
  attrs = {
    id     = "bucket-unlinked"
    bucket = "bucket-unlinked"
  }
}

