# ==============================================================================
# organizations.tf - ガバナンス・SCP（サービスコントロールポリシー）管理
# ==============================================================================

# ------------------------------------------------------------------------------
# 4. Data Sources (既存の組織情報を参照)
# ------------------------------------------------------------------------------
# 手動で作ったOrganizationsの情報を取得
data "aws_organizations_organization" "my_org" {}

# ------------------------------------------------------------------------------
# 5. Service Control Policy (SCP) Definition
# ------------------------------------------------------------------------------
# 東京リージョン以外での操作を禁止するSCP（グローバルサービスは除外）
resource "aws_organizations_policy" "deny_outside_tokyo" {
  name        = "deny-outside-tokyo-policy"
  description = "Deny all requests outside ap-northeast-1 except global services" # 👈 元の記述に完全復元
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyAllOutsideTokyoExceptGlobalServices"
        Effect = "Deny"

        # ❌ 以下のグローバルサービス「以外」で、東京リージョン外への操作があれば拒否
        NotAction = [
          "iam:*",
          "organizations:*",
          "route53:*",
          "cloudfront:*",
          "support:*",
          "cloudtrail:*", # 組織のTrail運用のために除外推奨

          # 👇 他リージョンのCloudWatchアラームの「参照」だけは、SCPの拒否から外す
          "monitoring:Describe*",
          "monitoring:Get*",
          "monitoring:List*"
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "ap-northeast-1"
            ]
          }
        }
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# 6. Policy Attachment (OUやアカウントへの紐付け)
# ------------------------------------------------------------------------------
# 作成したSCPを、手動で作ったOU（Prod OU や Repo OU）にアタッチする設定
resource "aws_organizations_policy_attachment" "prod_ou_attachment" {
  policy_id = aws_organizations_policy.deny_outside_tokyo.id
  target_id = var.ou_ids.prod # ★ Prod環境のOU IDを指定
}

resource "aws_organizations_policy_attachment" "repo_ou_attachment" {
  policy_id = aws_organizations_policy.deny_outside_tokyo.id
  target_id = var.ou_ids.repo # ★ Repo環境のOU IDを指定
}

resource "aws_organizations_policy_attachment" "sandbox_ou_attachment" {
  policy_id = aws_organizations_policy.deny_outside_tokyo.id
  target_id = var.ou_ids.sandbox # ★ Sandbox環境のOU IDを指定
}
