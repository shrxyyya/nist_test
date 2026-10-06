# Copyright IBM Corp. 2026

policytest {
  targets = [
    "lambda-function-xray-enabled.policy.hcl"
  ]
}

resource "aws_lambda_function" "pass_tracing_mode_active" {
  attrs = {
    filename      = "lambda_function_payload.zip"
    function_name = "lambda7-active-tracing"
    role          = "arn:aws:iam::123456789012:role/lambda_basic_execution"
    tracing_config = [{
      mode = "Active"
    }]
  }
}

resource "aws_lambda_function" "fail_tracing_mode_passthrough" {
  expect_failure = true
  attrs = {
    filename      = "lambda_function_payload.zip"
    function_name = "lambda7-passthrough-tracing"
    role          = "arn:aws:iam::123456789012:role/lambda_basic_execution"
    tracing_config = [{
      mode = "PassThrough"
    }]
  }
}

resource "aws_lambda_function" "fail_tracing_config_absent" {
  expect_failure = true
  attrs = {
    filename      = "lambda_function_payload.zip"
    function_name = "lambda7-tracing-absent"
    role          = "arn:aws:iam::123456789012:role/lambda_basic_execution"
  }
}

resource "aws_lambda_function" "fail_tracing_config_null" {
  expect_failure = true
  attrs = {
    filename        = "lambda_function_payload.zip"
    function_name   = "lambda7-tracing-null"
    role            = "arn:aws:iam::123456789012:role/lambda_basic_execution"
    tracing_config  = null
  }
}

resource "aws_lambda_function" "fail_tracing_config_empty" {
  expect_failure = true
  attrs = {
    filename        = "lambda_function_payload.zip"
    function_name   = "lambda7-tracing-empty"
    role            = "arn:aws:iam::123456789012:role/lambda_basic_execution"
    tracing_config  = []
  }
}
