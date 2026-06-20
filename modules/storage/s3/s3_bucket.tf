# ----------------------------
# S3バケット作成
# → EC2からS3へパッケージを参照・更新するためのバケットを作成
# ----------------------------
resource "aws_s3_bucket" "this" {
  bucket        = var.s3_bucket_name
  force_destroy = true

  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-s3"
  })
}

#バージョニング設定(対象バケットのファイルのバージョン履歴を持つようにすること)
resource "aws_s3_bucket_versioning" "main" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ----------------------------
# S3バケットポリシー (既存の許可にProd EC2用を追加)
# ----------------------------
resource "aws_s3_bucket_policy" "restrict_access" {
  bucket = aws_s3_bucket.this.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # ▼ ここは既存のまま（いじらない）
      {
        Sid    = "AllowIAMAccess"
        Effect = "Allow"
        Principal = {
          "AWS" : var.allowed_principal_arns
        }
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]
        # 💡指定されたVPCエンドポイントIDのみ許可する設定
        Condition = {
          StringEquals = {
            "aws:sourceVpce" = var.vpc_endpoint_id
          }
        }
      },

      # ★★ ここから追加分 ★★
      {
        Sid    = "AllowCrossAccountProdEC2Access"
        Effect = "Allow"
        # 💡 【思考資産: 鶏と卵問題の回避】
        # Repo環境構築時点ではProdのIAMロールが存在しないため、Principalに直接ロールARNを書くと
        # AWS側の実在チェックでInvalidPrincipalエラーとなりPlan/Applyが完全に崩壊する。
        # 回避のため、Principalは確定で実在する「ProdのRoot（アカウントID）」をハードコードで固定し、
        # 具体的なロールの絞り込みは実在チェックが入らない下の「Condition（ArnLike）」に逃がす設計。
        # 
        # ⚠️ 注意: data.aws_organizations_organizationによる動的取得は、
        # OrganizationAccountAccessRoleにAssumeRoleした状態（子アカウント実行）だと
        # API仕様でaccountsリストが強制的にnullになりエラーを吐くため、ここでの動的解決は不可。
        Principal = {
          "AWS" : "arn:aws:iam::968477972809:root"
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.this.arn,
          "${aws_s3_bucket.this.arn}/*"
        ]
        # 実際のアクセス時に、Prod側で作られるEC2ロールに限定する
        Condition = {
          "ArnLike" : {
            "aws:PrincipalArn" : "arn:aws:iam::968477972809:role/prod_ec2_role"
          }
        }
      }
      # ★★ ここまで追加分 ★★
    ]
  })
}
