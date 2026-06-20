# ==============================================================================
# iam.tf - 他アカウント（Repo/Prod）からのアクセス権限管理
# 
# 主な役割:
#   - 他アカウントからmanagementのS3へアクセスするためのIAM Roleの管理
# ==============================================================================

# ------------------------------------------------------------------------------
# 3. IAM Cross-Account Access Configuration
# ------------------------------------------------------------------------------
# RepoとProdアカウントがこのS3にアクセスするためのIAM Role
resource "aws_iam_role" "tfstate_access" {
  name = "tfstate-access-from-other-accounts"

  # RepoとProdがこのRoleを引き受けることを許可
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "sts:AssumeRole"
        Principal = {
          AWS = [
            "arn:aws:iam::${var.account_ids.repo}:root",   # RepoアカウントID
            "arn:aws:iam::${var.account_ids.prod}:root",   # ProdアカウントID
            "arn:aws:iam::${var.account_ids.sandbox}:root" # sandoboxアカウントID
          ]
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "tfstate-access-role"
  })
}

# このRoleにS3への読み書き権限を付与
resource "aws_iam_role_policy" "tfstate_access" {
  name = "tfstate-full-access"
  role = aws_iam_role.tfstate_access.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.tfstate.arn,
          "${aws_s3_bucket.tfstate.arn}/*"
        ]
      }
    ]
  })
}
