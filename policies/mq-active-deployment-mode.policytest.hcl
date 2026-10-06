# Copyright IBM Corp. 2026

policytest {
  targets = ["mq-active-deployment-mode.policy.hcl"]
}

resource "aws_mq_broker" "pass_active_standby" {
  attrs = {
    broker_name        = "b1"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.t3.micro"
    deployment_mode    = "ACTIVE_STANDBY_MULTI_AZ"
  }
}

resource "aws_mq_broker" "pass_cluster_multi_az" {
  attrs = {
    broker_name        = "b2"
    engine_type        = "RabbitMQ"
    engine_version     = "3.13"
    host_instance_type = "mq.m5.large"
    deployment_mode    = "CLUSTER_MULTI_AZ"
  }
}

resource "aws_mq_broker" "fail_single_instance" {
  expect_failure = true
  attrs = {
    broker_name        = "b3"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.t3.micro"
    deployment_mode    = "SINGLE_INSTANCE"
  }
}

resource "aws_mq_broker" "fail_deployment_mode_omitted" {
  expect_failure = true
  attrs = {
    broker_name        = "b4"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.t3.micro"
  }
}

resource "aws_mq_broker" "fail_deployment_mode_null" {
  expect_failure = true
  attrs = {
    broker_name        = "b5"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.t3.micro"
    deployment_mode    = null
  }
}

resource "aws_mq_broker" "fail_empty_deployment_mode" {
  expect_failure = true
  attrs = {
    broker_name        = "b6"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.t3.micro"
    deployment_mode    = ""
  }
}

resource "aws_mq_broker" "skip_rabbitmq_engine_type" {
  skip = true
  attrs = {
    broker_name        = "b7"
    engine_type        = "RabbitMQ"
    engine_version     = "3.13"
    host_instance_type = "mq.m5.large"
    deployment_mode    = "SINGLE_INSTANCE"
  }
}
