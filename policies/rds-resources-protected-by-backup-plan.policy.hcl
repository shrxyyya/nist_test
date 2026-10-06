# Copyright IBM Corp. 2026

# RDS DB instances should be protected by a backup plan

policy {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.65.0, < 7.0.0"
    }
  }
}

input "rds-resources-protected-by-backup-plan-enforcement-level" {
  type    = string
  default = "advisory"
}

# backupVaultLockCheck: When set to true, additionally verifies that the AWS Backup vault
# associated with the backup plan protecting the RDS instance has Vault Lock enabled
input "backupVaultLockCheck" {
  type    = string
  default = "false"
}

locals {
  rds_all_backup_selections           = core::getresources("aws_backup_selection", {})
  rds_all_backup_plans                = core::getresources("aws_backup_plan", {})
  rds_all_vault_lock_configurations   = core::getresources("aws_backup_vault_lock_configuration", {})

  locked_vault_names = core::try([
    for vlc in local.rds_all_vault_lock_configurations :
    core::try(vlc.backup_vault_name, "")
    if (core::try(vlc.backup_vault_name, null) != null ? core::try(vlc.backup_vault_name, "") != "" : false)
  ], [])
}

resource_policy "aws_db_instance" "rds_protected_by_backup_plan" {
  enforcement_level = input.rds-resources-protected-by-backup-plan-enforcement-level

  locals {
    db_arn_raw = core::try(attrs.arn, null)
    db_arn     = local.db_arn_raw != null ? local.db_arn_raw : ""

    direct_arn_selections = core::try([
      for sel in local.rds_all_backup_selections : sel
      if local.db_arn != ""
        && core::contains((core::try(sel.resources, null) != null ? core::try(sel.resources, []) : []), local.db_arn)
    ], [])

    tag_based_selections = core::try([
      for sel in local.rds_all_backup_selections : sel
      if (
        core::length(core::try(sel.selection_tag, null) != null ? core::try(sel.selection_tag, []) : []) > 0
        || core::length(core::try(sel.condition, null) != null ? core::try(sel.condition, []) : []) > 0
      )
    ], [])

    is_covered_by_direct_arn  = core::length(local.direct_arn_selections) > 0
    is_covered_by_tag         = core::length(local.tag_based_selections) > 0
    is_covered                = local.is_covered_by_direct_arn || local.is_covered_by_tag

    vault_lock_check_enabled = input.backupVaultLockCheck == "true"

    associated_vault_names = core::try(core::flatten([
      for sel in local.direct_arn_selections :
      core::try(core::flatten([
        for plan in local.rds_all_backup_plans :
        core::try([
          for rule in core::try(plan.rule, []) : core::try(rule.target_vault_name, "")
          if (core::try(rule.target_vault_name, null) != null ? core::try(rule.target_vault_name, "") != "" : false)
        ], [])
        if (core::try(plan.id, null) != null ? core::try(plan.id, "") != "" && core::try(plan.id, "") == core::try(sel.plan_id, "") : false)
      ]), [])
    ]), [])

    unlocked_vault_names = core::try([
      for vault_name in local.associated_vault_names : vault_name
      if vault_name != null && vault_name != "" && !core::contains(local.locked_vault_names, vault_name)
    ], [])

    all_vaults_locked = core::length(local.unlocked_vault_names) == 0
  }

  enforce {
    condition     = local.is_covered
    error_message = "RDS DB instance is not protected by any AWS Backup plan. Add an aws_backup_selection that references this instance's ARN in 'resources', or add a tag-based selection (selection_tag or condition) that matches the instance."
  }

  enforce {
    condition     = !local.vault_lock_check_enabled || !local.is_covered_by_direct_arn || local.all_vaults_locked
    error_message = "RDS DB instance is protected by backup plan(s) whose vault(s) do not have Vault Lock enabled: [${core::join(", ", local.unlocked_vault_names)}]. Configure aws_backup_vault_lock_configuration for each vault to satisfy the backupVaultLockCheck requirement."
  }
}
