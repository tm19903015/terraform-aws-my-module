# ----------------------------
# EC2作成
# → EC2を作成する。
# ----------------------------
# AMI指定
resource "aws_instance" "ec2" {
  ami                  = var.ec2_instance_define.ami
  instance_type        = var.ec2_instance_define.instance_type
  subnet_id            = var.public_subnets
  iam_instance_profile = var.iam_instance_profile

  vpc_security_group_ids = var.vpc_security_group_ids
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-ec2"
  })
  # dnfのレポジトリをS3に設定するuser_data_base64を設定
  user_data_base64 = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail
    # AL2023のbashで実行。全出力をログに記録
    exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

    # 変数設定（Terraform変数から注入）
    DIR="/tmp/repo"
    BUCKET_NAME="${var.s3_bucket_name}"

    # ツールインストール
    dnf install -y dnf-plugins-core createrepo

    # リポジトリ作成
    # $${$DIR} ではなく $${DIR} が正解
    mkdir -p $${DIR}
    cd $${DIR}

    # Apache(httpd) と依存パッケージを取得
    dnf download --resolve httpd mariadb114
    createrepo $${DIR}

    # S3へアップロード（EOFの内側に収める）
    aws s3 rm s3://$${BUCKET_NAME} --recursive || true
    aws s3 cp $${DIR} s3://$${BUCKET_NAME} --recursive
EOF
  )

}
