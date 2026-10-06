# Copyright IBM Corp. 2026

# Lambda functions should be in a VPC

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.67.0, < 7.0.0"
    }
  }
}

input "lambda-functions-should-be-in-a-vpc-enforcement-level" {
  type    = string
  default = "advisory"
}

resource_policy "aws_lambda_function" "lambda_functions_should_be_in_a_vpc" {
  locals {
    vpc_config_raw = core::try(attrs.vpc_config, null)
    vpc_config     = local.vpc_config_raw != null ? local.vpc_config_raw : []
    # Every vpc_config block must have non-empty subnet_ids and security_group_ids
    invalid_configs = [for c in local.vpc_config : c if(
      core::length(core::try(c.subnet_ids, null) != null ? c.subnet_ids : []) == 0 ||
      core::length(core::try(c.security_group_ids, null) != null ? c.security_group_ids : []) == 0
    )]
    is_compliant = core::length(local.vpc_config) > 0 && core::length(local.invalid_configs) == 0
  }

  enforcement_level = input.lambda-functions-should-be-in-a-vpc-enforcement-level
  enforce {
    condition     = local.is_compliant
    error_message = "Lambda functions must be deployed within a VPC with proper subnet_ids and security_group_ids configured"
  }
}
