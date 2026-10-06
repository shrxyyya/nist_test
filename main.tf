terraform {
  required_version = ">= 1.16.0"
  cloud {
    organization = "nagateja-test-org"
    workspaces {
      name = "nist-testing"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------------------------
# aws_mq_broker
# ---------------------------------------------------------------------------

resource "aws_mq_broker" "main" {
  broker_name        = "nist-test-broker"
  engine_type        = "ActiveMQ"
  engine_version     = "5.17.6"
  host_instance_type = "mq.t3.micro"

  user {
    username = "mqadmin"
    password = "Ch@ngeMe2024!"
  }
}

# ---------------------------------------------------------------------------
# aws_cloudwatch_event_endpoint
# ---------------------------------------------------------------------------

resource "aws_cloudwatch_event_endpoint" "main" {
  name = "nist-test-endpoint"

  event_bus {
    event_bus_arn = "arn:aws:events:us-east-1:123456789012:event-bus/default"
  }

  event_bus {
    event_bus_arn = "arn:aws:events:us-west-2:123456789012:event-bus/default"
  }

  routing_config {
    failover_config {
      primary {
        health_check = "arn:aws:route53:::healthcheck/abc12345-0000-0000-0000-000000000000"
      }
      secondary {
        route = "us-west-2"
      }
    }
  }
}

# ---------------------------------------------------------------------------
# aws_lambda_function
# ---------------------------------------------------------------------------

data "archive_file" "lambda_zip" {
  type        = "zip"
  output_path = "${path.module}/lambda.zip"
  source {
    content  = "def handler(event, context): return {'statusCode': 200}"
    filename = "index.py"
  }
}

resource "aws_iam_role" "lambda" {
  name = "nist-test-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_lambda_function" "main" {
  function_name = "nist-test-function"
  runtime       = "python3.12"
  handler       = "index.handler"
  role          = aws_iam_role.lambda.arn
  filename      = data.archive_file.lambda_zip.output_path
}

# ---------------------------------------------------------------------------
# aws_msk_cluster
# ---------------------------------------------------------------------------

resource "aws_msk_cluster" "main" {
  cluster_name           = "nist-test-cluster"
  kafka_version          = "3.6.0"
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.t3.small"
    client_subnets  = ["subnet-aaaaaaaa", "subnet-bbbbbbbb", "subnet-cccccccc"]
    security_groups = ["sg-00000000000000000"]

    storage_info {
      ebs_storage_info {
        volume_size = 20
      }
    }
  }
}

# ---------------------------------------------------------------------------
# aws_neptune_cluster
# ---------------------------------------------------------------------------

resource "aws_neptune_cluster" "main" {
  cluster_identifier  = "nist-test-neptune"
  engine              = "neptune"
  skip_final_snapshot = true
  apply_immediately   = true
}

# ---------------------------------------------------------------------------
# aws_networkfirewall_firewall
# ---------------------------------------------------------------------------

resource "aws_networkfirewall_firewall_policy" "main" {
  name = "nist-test-fw-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:drop"]
    stateless_fragment_default_actions = ["aws:drop"]
  }
}

resource "aws_networkfirewall_firewall" "main" {
  name                = "nist-test-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main.arn
  vpc_id              = "vpc-00000000000000000"

  subnet_mapping {
    subnet_id = "subnet-aaaaaaaa"
  }
}

# ---------------------------------------------------------------------------
# aws_opensearch_domain
# ---------------------------------------------------------------------------

resource "aws_opensearch_domain" "main" {
  domain_name    = "nist-test-domain"
  engine_version = "OpenSearch_2.13"

  ebs_options {
    ebs_enabled = true
    volume_size = 10
  }
}

# ---------------------------------------------------------------------------
# rds_all_backup_selections  →  aws_backup_selection
# rds_all_backup_plans       →  aws_backup_plan
# rds_all_vault_lock_configurations  →  aws_backup_vault_lock_configuration
# ---------------------------------------------------------------------------

resource "aws_backup_vault" "main" {
  name = "nist-test-vault"
}

resource "aws_backup_plan" "main" {
  name = "nist-test-backup-plan"

  rule {
    rule_name         = "daily-backup"
    target_vault_name = aws_backup_vault.main.name
    schedule          = "cron(0 3 * * ? *)"
  }
}

resource "aws_iam_role" "backup" {
  name = "nist-test-backup-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "backup.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_backup_selection" "main" {
  name         = "nist-test-selection"
  plan_id      = aws_backup_plan.main.id
  iam_role_arn = aws_iam_role.backup.arn
  resources    = ["arn:aws:rds:us-east-1:123456789012:db:nist-test-db"]
}

resource "aws_backup_vault_lock_configuration" "main" {
  backup_vault_name  = aws_backup_vault.main.name
  min_retention_days = 7
}

# ---------------------------------------------------------------------------
# aws_db_instance
# ---------------------------------------------------------------------------

resource "aws_db_instance" "main" {
  identifier     = "nist-test-db"
  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.medium"

  allocated_storage = 20
  username          = "dbadmin"
  password          = "Ch@ngeMe2024!"

  skip_final_snapshot = true
}

# ---------------------------------------------------------------------------
# aws_redshiftserverless_namespace
# ---------------------------------------------------------------------------

resource "aws_redshiftserverless_namespace" "main" {
  namespace_name = "nist-test-namespace"
}

# ---------------------------------------------------------------------------
# aws_s3_bucket + related resources
# ---------------------------------------------------------------------------

resource "aws_s3_bucket" "main" {
  bucket = "nist-test-bucket-main"
}

resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.main.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_replication_configuration" "main" {
  bucket = aws_s3_bucket.main.id
  role   = aws_iam_role.s3_replication.arn

  rule {
    id     = "replicate-all"
    status = "Enabled"

    destination {
      bucket        = "arn:aws:s3:::nist-test-bucket-replica"
      storage_class = "STANDARD"
    }
  }

  depends_on = [aws_s3_bucket_versioning.main]
}

resource "aws_iam_role" "s3_replication" {
  name = "nist-test-s3-replication-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "s3.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "main" {
  bucket = aws_s3_bucket.main.id

  rule {
    id     = "expire-objects"
    status = "Enabled"
    filter {}

    expiration {
      days = 365
    }
  }
}

# ---------------------------------------------------------------------------
# aws_sagemaker_feature_group
# ---------------------------------------------------------------------------

resource "aws_iam_role" "sagemaker" {
  name = "nist-test-sagemaker-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "sagemaker.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_sagemaker_feature_group" "main" {
  feature_group_name             = "nist-test-feature-group"
  record_identifier_feature_name = "record_id"
  event_time_feature_name        = "event_time"
  role_arn                       = aws_iam_role.sagemaker.arn

  feature_definition {
    feature_name = "record_id"
    feature_type = "Integral"
  }

  feature_definition {
    feature_name = "event_time"
    feature_type = "Fractional"
  }

  offline_store_config {
    s3_storage_config {
      s3_uri = "s3://nist-test-bucket-main/feature-store"
    }
  }
}

# ---------------------------------------------------------------------------
# aws_sns_topic
# ---------------------------------------------------------------------------

resource "aws_sns_topic" "main" {
  name = "nist-test-topic"
}
