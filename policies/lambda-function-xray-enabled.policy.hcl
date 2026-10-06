# Copyright IBM Corp. 2026

# Lambda functions should have AWS X-Ray active tracing enabled

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "lambda-function-xray-enabled-enforcement-level" {
    type = string
    default = "advisory"
}

resource_policy "aws_lambda_function" "lambda_xray_active_tracing" {
    enforcement_level = input.lambda-function-xray-enabled-enforcement-level

    locals {
        tracing_config_blocks_raw = core::try(attrs.tracing_config, null)
        tracing_config_blocks = local.tracing_config_blocks_raw != null ? local.tracing_config_blocks_raw : []
        has_tracing_config = core::length(local.tracing_config_blocks) > 0
        tracing_mode_raw = local.has_tracing_config ? core::try(local.tracing_config_blocks[0].mode, null) : null
        tracing_mode = local.tracing_mode_raw == null ? "" : local.tracing_mode_raw
    }

    enforce {
        condition = local.tracing_mode == "Active"
        error_message = "Lambda function must have AWS X-Ray active tracing enabled (tracing_config { mode = \"Active\" }). Current mode: '${local.tracing_mode}'."
    }
}
