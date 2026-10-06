# Copyright IBM Corp. 2026

policytest {
  targets = ["lambda-functions-should-be-in-a-vpc.policy.hcl"]
}

resource "aws_lambda_function" "pass_valid_vpc_config" {
  attrs = {
    function_name = "f1"
    role          = "arn:aws:iam::123456789012:role/test"
    vpc_config = [{
      subnet_ids         = ["subnet-1", "subnet-2"]
      security_group_ids = ["sg-1"]
    }]
  }
}

resource "aws_lambda_function" "fail_no_vpc_config" {
  expect_failure = true
  attrs = {
    function_name = "f2"
    role          = "arn:aws:iam::123456789012:role/test"
  }
}

resource "aws_lambda_function" "fail_null_vpc_config" {
  expect_failure = true
  attrs = {
    function_name = "f3"
    role          = "arn:aws:iam::123456789012:role/test"
    vpc_config    = null
  }
}

resource "aws_lambda_function" "fail_empty_vpc_config_list" {
  expect_failure = true
  attrs = {
    function_name = "f4"
    role          = "arn:aws:iam::123456789012:role/test"
    vpc_config    = []
  }
}

resource "aws_lambda_function" "fail_empty_subnet_ids" {
  expect_failure = true
  attrs = {
    function_name = "f5"
    role          = "arn:aws:iam::123456789012:role/test"
    vpc_config = [{
      subnet_ids         = []
      security_group_ids = ["sg-1"]
    }]
  }
}

resource "aws_lambda_function" "fail_empty_security_group_ids" {
  expect_failure = true
  attrs = {
    function_name = "f6"
    role          = "arn:aws:iam::123456789012:role/test"
    vpc_config = [{
      subnet_ids         = ["subnet-1"]
      security_group_ids = []
    }]
  }
}

resource "aws_lambda_function" "fail_null_security_group_ids" {
  expect_failure = true
  attrs = {
    function_name = "f7"
    role          = "arn:aws:iam::123456789012:role/test"
    vpc_config = [{
      subnet_ids         = ["subnet-1"]
      security_group_ids = null
    }]
  }
}

resource "aws_lambda_function" "fail_both_empty" {
  expect_failure = true
  attrs = {
    function_name = "f8"
    role          = "arn:aws:iam::123456789012:role/test"
    vpc_config = [{
      subnet_ids         = []
      security_group_ids = []
    }]
  }
}

