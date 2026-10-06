# Copyright IBM Corp. 2026

# S3 buckets should have event notifications enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "s3-bucket-should-have-event-notifications-enabled-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_s3_bucket" "event_notifications_enabled" {
  locals {
    notifications = core::getresources("aws_s3_bucket_notification", {
      bucket = attrs.id
    })
    # A notification only counts when it defines at least one topic block (null-safe).
    notifications_with_topic = [
      for n in local.notifications : n
      if core::length(core::try(n.topic, null) != null ? n.topic : []) > 0
    ]
  }

  enforcement_level = input.s3-bucket-should-have-event-notifications-enabled-enforcement-level
  enforce {
    condition     = core::length(local.notifications_with_topic) > 0
    error_message = "S3 Buckets should have event notifications enabled"
  }
}
