# Copyright IBM Corp. 2026

# SageMaker feature group online stores with standard storage should be encrypted with AWS KMS keys

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "sagemaker-featuregroup-online-store-encryption-enforcement-level" {
    type = string
    default = "advisory"
}

resource_policy "aws_sagemaker_feature_group" "online-store-encryption" {
    enforcement_level = input.sagemaker-featuregroup-online-store-encryption-enforcement-level

    locals {
      online_store_config_raw = core::try(attrs.online_store_config, null)
      online_store_config = local.online_store_config_raw != null ? local.online_store_config_raw : []
      has_online_store_config = core::length(local.online_store_config) > 0
      enable_online_store_raw = local.has_online_store_config ? core::try(local.online_store_config[0].enable_online_store, null) : null
      enable_online_store = local.enable_online_store_raw == null ? false : local.enable_online_store_raw
      storage_type_raw = local.has_online_store_config ? core::try(local.online_store_config[0].storage_type, null) : null
      storage_type = local.storage_type_raw == null ? "" : local.storage_type_raw

      security_config_raw = local.has_online_store_config ? core::try(local.online_store_config[0].security_config, null) : null
      security_config = local.security_config_raw != null ? local.security_config_raw : []
      kms_key_id_raw = core::length(local.security_config) > 0 ? core::try(local.online_store_config[0].security_config[0].kms_key_id) : null
      kms_key_id = local.kms_key_id_raw == null ? "" : local.kms_key_id_raw
    }

    filter = local.has_online_store_config && local.enable_online_store == true && local.storage_type == "Standard"

    enforce {
      condition = local.kms_key_id != ""
      error_message = "SageMaker feature group must have KMS encryption enabled for OnlineStore with standard storage (online_store_config { security_config { kms_key_id = \"<key>\" } }). Current kms_key_id: '${local.kms_key_id}'."
    }
}
