# ==============================================================================
# variables.tf
# 
# 主な役割:
#   - management アカウントで使う共通変数の型と説明の定義
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Base Variables
# ------------------------------------------------------------------------------
variable "region" {
  description = "使用するAWSリージョン"
  type        = string
}

variable "project_name" {
  description = "プロジェクト名（S3バケット名などに使用）"
  type        = string
}

# ------------------------------------------------------------------------------
# 2. Account & Tagging Variables
# ------------------------------------------------------------------------------
variable "account_ids" {
  description = "各アカウントID"
  type = object({
    management = string
    repo       = string
    prod       = string
    sandbox    = string
  })
}

variable "common_tags" {
  description = "共通タグ"
  type        = map(string)
}

variable "sso_username" {
  description = "The username of the AWS IAM Identity Center user"
  type        = string
}

# ------------------------------------------------------------------------------
# 3. AWS OU IDs
# ------------------------------------------------------------------------------
# OUID
variable "ou_ids" {
  description = "各OUのID"
  type = object({
    repo    = string
    prod    = string
    sandbox = string
  })
}
