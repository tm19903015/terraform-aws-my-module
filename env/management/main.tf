# ==============================================================================
# main.tf - management アカウント用
# 
# 主な役割:
#   - management自身、および他アカウント（Repo/Prod）のtfstate保存場所（S3）の管理
# ==============================================================================

# ------------------------------------------------------------------------------
# 0. Terraform Settings & Backend
# ------------------------------------------------------------------------------
terraform {
  required_version = ">= 1.5"

  backend "s3" {
    bucket  = "tm-tfstate-503782778940"
    key     = "env/management/terraform.tfstate" # ★repo環境ではここを env/repo/... に変更
    region  = "ap-northeast-1"
    encrypt = true
  }
}

# ------------------------------------------------------------------------------
# 1. Data Sources
# ------------------------------------------------------------------------------
# 現在のAWSアカウントIDを取得（動的に使うため）
data "aws_caller_identity" "current" {}

# ------------------------------------------------------------------------------
# 2. S3 Bucket for tfstate
# ------------------------------------------------------------------------------
# tfstateを保存するためのS3バケット
resource "aws_s3_bucket" "tfstate" {
  bucket        = "${var.project_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # destroy時に中身があっても強制削除できるように

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-bucket"
  })
}

# バージョニングを有効化（誤削除対策）
resource "aws_s3_bucket_versioning" "tfstate" {
  bucket = aws_s3_bucket.tfstate.id

  versioning_configuration {
    status = "Enabled"
  }
}
