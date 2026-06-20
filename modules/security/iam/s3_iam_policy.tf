# ----------------------------
# S3向けのIAMポリシー作成
# → EC2からS3へパッケージを参照・更新するためのポリシー作成
# ----------------------------
resource "aws_iam_policy" "s3_access" {
  count  = var.create_ec2_iam_role ? 1 : 0
  name   = "${var.common_tags["Env"]}-s3-access-policy"
  policy = data.aws_iam_policy_document.s3_access.json
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-s3-access-policy"
  })
}
data "aws_iam_policy_document" "s3_access" {
  statement {
    actions = var.create_s3_bucket ? [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:PutObject"
      ] : [
      "s3:ListBucket",
      "s3:GetObject"
    ]
    resources = ["*"]
  }
}

# ----------------------------
# 既存のEC2のIAMポリシーとアタッチ
# ----------------------------
resource "aws_iam_role_policy_attachment" "ec2_s3_attach" {
  # ロールが存在する場合のみアタッチを実行（安全策）
  count = var.create_ec2_iam_role ? 1 : 0
  # securityモジュールから出たロール名
  role = aws_iam_role.ec2_role[count.index].name
  # storageモジュールから出たポリシーARN
  policy_arn = aws_iam_policy.s3_access[count.index].arn
}

