# Copyright IBM Corp. 2026

policytest {
  targets = [
    "rds-resources-protected-by-backup-plan.policy.hcl"
  ]
}

resource "aws_backup_plan" "tag_plan_direct" {
  skip = true
  attrs = {
    id   = "tag-plan-direct-001"
    name = "rds-tag-backup-plan"
    rule = [
      {
        rule_name         = "daily-backup"
        target_vault_name = "rds-tag-backup-vault"
        schedule          = "cron(0 5 ? * * *)"
      }
    ]
  }
}

# TEST 1 — PASS: RDS instance covered by selection_tag
resource "aws_db_instance" "pass_tag_based_coverage" {
  attrs = {
    arn        = "arn:aws:rds:us-east-1:123456789012:db:tag-pass-tag"
    identifier = "tag-pass-tag"
  }
}

resource "aws_backup_selection" "pass_tag_selection" {
  skip = true
  attrs = {
    plan_id      = "tag-plan-direct-001"
    name         = "rds-tag-selection"
    iam_role_arn = "arn:aws:iam::123456789012:role/BackupRole"
    selection_tag = [
      {
        type  = "STRINGEQUALS"
        key   = "backup"
        value = "true"
      }
    ]
  }
}

# TEST 2 — PASS: RDS instance covered by a condition block
resource "aws_db_instance" "pass_condition_based_coverage" {
  attrs = {
    arn        = "arn:aws:rds:us-east-1:123456789012:db:tag-pass-condition"
    identifier = "tag-pass-condition"
  }
}

resource "aws_backup_selection" "pass_condition_selection" {
  skip = true
  attrs = {
    plan_id      = "tag-plan-direct-001"
    name         = "rds-condition-selection"
    iam_role_arn = "arn:aws:iam::123456789012:role/BackupRole"
    condition = [
      {
        string_equals = [
          {
            key   = "aws:ResourceTag/env"
            value = "prod"
          }
        ]
      }
    ]
  }
}

# TEST 3 — PASS: selection has resources omitted (null)
resource "aws_db_instance" "pass_null_resources_with_tag_fallback" {
  attrs = {
    arn        = "arn:aws:rds:us-east-1:123456789012:db:tag-pass-null-resources"
    identifier = "tag-pass-null-resources"
  }
}

resource "aws_backup_selection" "pass_null_resources_selection" {
  skip = true
  attrs = {
    plan_id      = "tag-plan-direct-001"
    name         = "rds-null-resources-selection"
    iam_role_arn = "arn:aws:iam::123456789012:role/BackupRole"
    # resources intentionally omitted — exercises the null-resources ternary guard
    selection_tag = [
      {
        type  = "STRINGEQUALS"
        key   = "backup"
        value = "true"
      }
    ]
  }
}

# TEST 4 — PASS: RDS instance covered by both a direct-ARN selection and a
# tag-based selection — verifies both coverage paths can coexist
resource "aws_db_instance" "pass_multiple_selections" {
  attrs = {
    arn        = "arn:aws:rds:us-east-1:123456789012:db:tag-pass-multi-sel"
    identifier = "tag-pass-multi-sel"
  }
}

resource "aws_backup_selection" "pass_multi_direct" {
  skip = true
  attrs = {
    plan_id      = "tag-plan-direct-001"
    name         = "rds-multi-direct"
    iam_role_arn = "arn:aws:iam::123456789012:role/BackupRole"
    resources    = ["arn:aws:rds:us-east-1:123456789012:db:tag-pass-multi-sel"]
  }
}

resource "aws_backup_selection" "pass_multi_tag" {
  skip = true
  attrs = {
    plan_id      = "tag-plan-direct-001"
    name         = "rds-multi-tag"
    iam_role_arn = "arn:aws:iam::123456789012:role/BackupRole"
    selection_tag = [
      {
        type  = "STRINGEQUALS"
        key   = "backup"
        value = "true"
      }
    ]
  }
}
