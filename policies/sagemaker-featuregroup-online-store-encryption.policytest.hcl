# Copyright IBM Corp. 2026

policytest {
  targets = [
    "sagemaker-featuregroup-online-store-encryption.policy.hcl"
  ]
}

# PASS: online store with standard storage, glue disabled, and KMS key set
resource "aws_sagemaker_feature_group" "pass_kms_key_set" {
  attrs = {
    feature_group_name             = "fg-pass-kms-set"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
    online_store_config = [{
      enable_online_store = true
      storage_type                = "Standard"
      security_config = [{
        kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc12345"
      }]
    }]
  }
}

# FAIL: filter matches but kms_key_id is an empty string
resource "aws_sagemaker_feature_group" "fail_kms_key_empty_string" {
  expect_failure = true
  attrs = {
    feature_group_name             = "fg-fail-kms-empty"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
    online_store_config = [{
      enable_online_store = true
      storage_type                = "Standard"
      security_config = [{
        kms_key_id = ""
      }]
    }]
  }
}

# FAIL: filter matches but kms_key_id is absent from security_config
resource "aws_sagemaker_feature_group" "fail_kms_key_absent" {
  expect_failure = true
  attrs = {
    feature_group_name             = "fg-fail-kms-absent"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
    online_store_config = [{
      enable_online_store = true
      storage_type                = "Standard"
      security_config             = [{}]
    }]
  }
}

# FAIL: filter matches but kms_key_id is null
resource "aws_sagemaker_feature_group" "fail_kms_key_null" {
  expect_failure = true
  attrs = {
    feature_group_name             = "fg-fail-kms-null"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
    online_store_config = [{
      enable_online_store = true
      storage_type                = "Standard"
      security_config = [{
        kms_key_id = null
      }]
    }]
  }
}

# FAIL: filter matches but security_config block is empty list
resource "aws_sagemaker_feature_group" "fail_security_config_empty" {
  expect_failure = true
  attrs = {
    feature_group_name             = "fg-fail-security-empty"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
    online_store_config = [{
      enable_online_store = true
      storage_type                = "Standard"
      security_config             = []
    }]
  }
}

# FAIL: filter matches but security_config is absent entirely
resource "aws_sagemaker_feature_group" "fail_security_config_absent" {
  expect_failure = true
  attrs = {
    feature_group_name             = "fg-fail-security-absent"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
    online_store_config = [{
      enable_online_store = true
      storage_type                = "Standard"
    }]
  }
}

# SKIP: online_store_config is absent — filter does not match, not evaluated
resource "aws_sagemaker_feature_group" "skip_no_online_store_config" {
  attrs = {
    feature_group_name             = "fg-skip-no-online-store"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
  }
}

# SKIP: online_store_config is null — filter does not match, not evaluated
resource "aws_sagemaker_feature_group" "skip_online_store_config_null" {
  attrs = {
    feature_group_name             = "fg-skip-online-store-null"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
    online_store_config            = null
  }
}

# SKIP: enable_online_store is false — filter does not match, not evaluated
resource "aws_sagemaker_feature_group" "skip_glue_not_disabled" {
  attrs = {
    feature_group_name             = "fg-skip-glue-not-disabled"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
    online_store_config = [{
      enable_online_store = false
      storage_type                = "Standard"
      security_config = [{
        kms_key_id = ""
      }]
    }]
  }
}

# SKIP: storage_type is not Standard — filter does not match, not evaluated
resource "aws_sagemaker_feature_group" "skip_storage_type_inmemorystorage" {
  attrs = {
    feature_group_name             = "fg-skip-inmemorystorage"
    record_identifier_feature_name = "record_id"
    event_time_feature_name        = "event_time"
    online_store_config = [{
      enable_online_store = true
      storage_type                = "InMemory"
      security_config = [{
        kms_key_id = ""
      }]
    }]
  }
}
