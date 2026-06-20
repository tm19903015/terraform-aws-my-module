# ----------------------------
# IAMロール作成
# → EC2 へ SSMを経由しているアクセスできるようにするためのロール作成
# ----------------------------
resource "aws_iam_role" "ec2_role" {

  # EC2関連のIAMロール作成フラグがtrueなら作成、falseなら作成しない。
  count = var.create_ec2_iam_role ? 1 : 0

  name               = "${var.common_tags["Env"]}_ec2_role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}_ec2_role"
  })
}

# ----------------------------
# ポリシー作成
# → EC2 へ SSMを経由しているアクセスできるようにするためのポリシー作成
# ----------------------------
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# ----------------------------
# IAMポリシーをEC2へ紐づけ
# → EC2 へ SSMを経由しているアクセスできるようにするためにIAMポリシーを紐づけ
# ----------------------------
resource "aws_iam_role_policy_attachment" "ssm_core" {
  # EC2関連のIAMロール作成フラグがtrueなら作成、falseなら作成しない。
  count = var.create_ec2_iam_role ? 1 : 0

  role       = aws_iam_role.ec2_role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ----------------------------
# EC2インスタンスのプロファイルを作成
# → EC2 へ SSMを経由してアクセスできるようにするためにEC2インスタンスのプロファイルを作成
# ----------------------------
resource "aws_iam_instance_profile" "ec2_profile" {
  # EC2関連のIAMロール作成フラグがtrueなら作成、falseなら作成しない。
  count = var.create_ec2_iam_role ? 1 : 0

  name = "${var.common_tags["Env"]}-ec2-profile"
  role = aws_iam_role.ec2_role[count.index].name
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-ec2-profile"
  })
}
