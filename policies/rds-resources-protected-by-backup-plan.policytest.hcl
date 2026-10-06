# Copyright IBM Corp. 2026

policytest {
  targets = [
    "rds-resources-protected-by-backup-plan.policy.hcl"
  ]
}

resource "aws_backup_plan" "plan_direct" {
  skip = true
  attrs = {
    id   = "plan-direct-001"
    name = "rds-direct-backup-plan"
    rule = [
      {
        rule_name         = "daily-backup"
        target_vault_name = "rds-backup-vault"
        schedule          = "cron(0 5 ? * * *)"
      }
    ]
  }
}

# TEST 1 — PASS: RDS instance covered by direct ARN in backup selection
resource "aws_db_instance" "pass_direct_arn_coverage" {
  attrs = {
    arn        = "arn:aws:rds:us-east-1:123456789012:db:pass-direct"
    identifier = "pass-direct"
  }
}

resource "aws_backup_selection" "pass_direct_arn_selection" {
  skip = true
  attrs = {
    plan_id      = "plan-direct-001"
    name         = "rds-direct-selection"
    iam_role_arn = "arn:aws:iam::123456789012:role/BackupRole"
    resources    = ["arn:aws:rds:us-east-1:123456789012:db:pass-direct"]
  }
}

# TEST 2 — FAIL: RDS instance with no backup selection at all
resource "aws_db_instance" "fail_no_backup_selection" {
  expect_failure = true
  attrs = {
    arn        = "arn:aws:rds:us-east-1:123456789012:db:fail-no-selection"
    identifier = "fail-no-selection"
  }
}

# TEST 3 — FAIL: A resources-only selection exists but lists a different ARN;
resource "aws_db_instance" "fail_arn_not_in_selection" {
  expect_failure = true
  attrs = {
    arn        = "arn:aws:rds:us-east-1:123456789012:db:fail-wrong-arn"
    identifier = "fail-wrong-arn"
  }
}

resource "aws_backup_selection" "fail_different_arn_selection" {
  skip = true
  attrs = {
    plan_id      = "plan-direct-001"
    name         = "rds-other-selection"
    iam_role_arn = "arn:aws:iam::123456789012:role/BackupRole"
    resources    = ["arn:aws:rds:us-east-1:123456789012:db:some-other-db"]
  }
}

# TEST 4 — FAIL: arn is omitted (computed/unknown at plan time); direct-ARN
resource "aws_db_instance" "fail_null_arn_no_coverage" {
  expect_failure = true
  attrs = {
    identifier = "fail-null-arn"
    # arn intentionally omitted — simulates a computed value unknown at plan time
  }
}
