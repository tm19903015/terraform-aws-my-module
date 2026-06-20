# ==============================================================================
# cloudtrail.tf - 組織全体の監査ログ（CloudTrail）一元集約管理
# ==============================================================================

# ------------------------------------------------------------------------------
# 7. S3 Bucket for Organization CloudTrail Logs
# ------------------------------------------------------------------------------
# 組織全体のCloudTrailログを集約して保存するための専用S3バケット
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket        = "tm-cloudtrail-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true # destroy時にログがあっても強制削除可能に

  tags = merge(var.common_tags, {
    Name = "tm-organization-cloudtrail-bucket"
  })
}

# ------------------------------------------------------------------------------
# 8. S3 Bucket Policy for CloudTrail Access
# ------------------------------------------------------------------------------
# CloudTrailサービスが、組織内の全アカウントのログをこのバケットに書き込めるようにするポリシー
resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSCloudTrailAclCheck"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:GetBucketAcl"
        Resource = aws_s3_bucket.cloudtrail_logs.arn
      },
      {
        Sid    = "AWSCloudTrailWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      },
      {
        Sid    = "AWSCloudTrailOrganizationWrite"
        Effect = "Allow"
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/AWSLogs/${data.aws_organizations_organization.my_org.id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# ------------------------------------------------------------------------------
# 9. AWS CloudTrail Configuration (Organization Trail)
# ------------------------------------------------------------------------------
# 組織全体のトレイルを有効化
resource "aws_cloudtrail" "org_trail" {
  name                          = "tm-organization-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  is_organization_trail         = true

  depends_on = [aws_s3_bucket_policy.cloudtrail_logs]

  tags = merge(var.common_tags, {
    Name = "tm-organization-trail"
  })
}
