# ----------------------------
# AWSからS3のプレフィックスリスト情報を取得する
# ----------------------------
data "aws_prefix_list" "s3" {
  name = "com.amazonaws.ap-northeast-1.s3"
}
