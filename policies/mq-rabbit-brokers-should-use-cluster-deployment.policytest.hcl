# Copyright IBM Corp. 2026

policytest {
  targets = ["mq-rabbit-brokers-should-use-cluster-deployment.policy.hcl"]
}

resource "aws_mq_broker" "rabbit_cluster_pass" {
  attrs = {
    broker_name        = "b1"
    engine_type        = "RabbitMQ"
    engine_version     = "3.13"
    host_instance_type = "mq.m5.large"
    deployment_mode    = "CLUSTER_MULTI_AZ"
  }
}

resource "aws_mq_broker" "rabbit_single_fail" {
  expect_failure = true
  attrs = {
    broker_name        = "b2"
    engine_type        = "RabbitMQ"
    engine_version     = "3.13"
    host_instance_type = "mq.m5.large"
    deployment_mode    = "SINGLE_INSTANCE"
  }
}

resource "aws_mq_broker" "rabbit_unset_fail" {
  expect_failure = true
  attrs = {
    broker_name        = "b3"
    engine_type        = "RabbitMQ"
    engine_version     = "3.13"
    host_instance_type = "mq.m5.large"
  }
}

resource "aws_mq_broker" "rabbit_null_fail" {
  expect_failure = true
  attrs = {
    broker_name        = "b4"
    engine_type        = "RabbitMQ"
    engine_version     = "3.13"
    host_instance_type = "mq.m5.large"
    deployment_mode    = null
  }
}

resource "aws_mq_broker" "rabbit_active_standby_fail" {
  expect_failure = true
  attrs = {
    broker_name        = "b5"
    engine_type        = "RabbitMQ"
    engine_version     = "3.13"
    host_instance_type = "mq.m5.large"
    deployment_mode    = "ACTIVE_STANDBY_MULTI_AZ"
  }
}

resource "aws_mq_broker" "activemq_single_pass" {
  attrs = {
    broker_name        = "b6"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.m5.large"
    deployment_mode    = "SINGLE_INSTANCE"
  }
}

resource "aws_mq_broker" "activemq_unset_pass" {
  attrs = {
    broker_name        = "b7"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.m5.large"
  }
}

resource "aws_mq_broker" "activemq_active_standby_pass" {
  attrs = {
    broker_name        = "b8"
    engine_type        = "ActiveMQ"
    engine_version     = "5.17.6"
    host_instance_type = "mq.m5.large"
    deployment_mode    = "ACTIVE_STANDBY_MULTI_AZ"
  }
}

