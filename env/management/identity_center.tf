# ==============================================================================
# identity_center.tf - Repo / Prod 専用の最小権限許可セットおよびアカウント割り当て
# ==============================================================================

# ------------------------------------------------------------------------------
# 10. 共通データソース & ローカル変数
# ------------------------------------------------------------------------------
# AWS IAM Identity Center のインスタンス情報を取得
data "aws_ssoadmin_instances" "this" {}

locals {
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
}

# 割り当て対象となるユーザーのIDを取得
data "aws_identitystore_user" "this" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName" # 👈 UserName で検索
      attribute_value = var.sso_username
    }
  }
}

# ------------------------------------------------------------------------------
# 11. Repo（検証環境）用 許可セット定義
# ------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "repo_developer" {
  name             = "tm-repo-developer-permission-set"
  description      = "Permission set for Repo environment based on actual CloudTrail logs"
  instance_arn     = local.instance_arn
  session_duration = "PT4H" # 検証用：4時間セッション
}

# ------------------------------------------------------------------------------
# 12. Repo（検証環境）用 インラインポリシーアタッチ
# ------------------------------------------------------------------------------
# 実績ログから抽出した「最小権限」インラインポリシー
resource "aws_ssoadmin_permission_set_inline_policy" "repo_developer_policy" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.repo_developer.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowRepoCoreServices"
        Effect = "Allow"
        Action = [
          "ec2:*",            # VPC、サブネット、IGW、SG、RouteTable、EC2インスタンス全般
          "s3:*",             # tfstate用バケット操作等
          "ssm:StartSession", # CloudShell/SSM経由のセッション
          "ssm:Describe*",
          "ssm:Get*",
          "ssm:RegisterManagedInstance",
          "ssm:UpdateInstanceInformation",
          "resource-explorer-2:*",
          "cloudshell:*",
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# 13. Repo（検証環境）用 アカウント割り当て
# ------------------------------------------------------------------------------
# 🤝 Repoアカウントへの割り当て（アカウントアサインメント）
resource "aws_ssoadmin_account_assignment" "repo" {
  instance_arn       = local.instance_arn
  target_id          = var.account_ids.repo
  target_type        = "AWS_ACCOUNT"
  permission_set_arn = aws_ssoadmin_permission_set.repo_developer.arn
  principal_id       = data.aws_identitystore_user.this.id
  principal_type     = "USER"
}

# ------------------------------------------------------------------------------
# 14. Prod（本番環境）用 許可セット定義
# ------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "prod_developer" {
  name             = "tm-prod-developer-permission-set"
  description      = "Permission set for Prod environment based on actual CloudTrail logs"
  instance_arn     = local.instance_arn
  session_duration = "PT2H" # 本番用：安全のため短めの2時間セッション
}

# ------------------------------------------------------------------------------
# 15. Prod（本番環境）用 インラインポリシーアタッチ
# ------------------------------------------------------------------------------
# 実績ログから抽出した「最小権限」インラインポリシー（追加された上位サービスを網羅）
resource "aws_ssoadmin_permission_set_inline_policy" "prod_developer_policy" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.prod_developer.arn

  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowProdCoreServices"
        Effect = "Allow"
        Action = [
          "ec2:*",                  # VPC、EIP、LaunchTemplate、VPCエンドポイント等
          "elasticloadbalancing:*", # ALB (Listener, TargetGroup等)
          "autoscaling:*",          # ASG (ScalingPolicy等)
          "rds:*",                  # RDS本体、DBサブネットグループ
          "cloudwatch:*",           # アラーム画面の表示に必須
          "sns:*",                  # アラーム通知用トピック、Subscribe/Unsubscribe
          "ssm:StartSession",       # 踏み台・トラブルシューティング用権限
          "ssm:Describe*",
          "ssm:Get*",
          "ssm:RegisterManagedInstance",
          "ssm:UpdateInstanceInformation",
          "resource-explorer-2:*",
          "cloudshell:*",
          "iam:Get*",
          "iam:List*"
        ]
        Resource = "*"
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# 16. Prod（本番環境）用 アカウント割り当て
# ------------------------------------------------------------------------------
# 🤝 Prodアカウントへの割り当て（アカウントアサインメント）
resource "aws_ssoadmin_account_assignment" "prod" {
  instance_arn       = local.instance_arn
  target_id          = var.account_ids.prod
  target_type        = "AWS_ACCOUNT"
  permission_set_arn = aws_ssoadmin_permission_set.prod_developer.arn
  principal_id       = data.aws_identitystore_user.this.id
  principal_type     = "USER"
}

# ------------------------------------------------------------------------------
# 17. Sandbox（検証環境）用 許可セット定義
# ------------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "sandbox" {
  name             = "tm-sandbox-permission-set"
  description      = "Permission set for Sandbox environment - AdministratorAccess equivalent for free verification"
  instance_arn     = local.instance_arn
  session_duration = "PT8H" # 検証用：長めの8時間セッション
}

# ------------------------------------------------------------------------------
# 18. Sandbox（検証環境）用 管理ポリシーアタッチ
# ------------------------------------------------------------------------------
resource "aws_ssoadmin_managed_policy_attachment" "sandbox_developer_policy" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.sandbox.arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# ------------------------------------------------------------------------------
# 19. Sandbox（検証環境）用 アカウント割り当て
# ------------------------------------------------------------------------------
resource "aws_ssoadmin_account_assignment" "sandbox" {
  instance_arn       = local.instance_arn
  target_id          = var.account_ids.sandbox
  target_type        = "AWS_ACCOUNT"
  permission_set_arn = aws_ssoadmin_permission_set.sandbox.arn
  principal_id       = data.aws_identitystore_user.this.id
  principal_type     = "USER"
}
