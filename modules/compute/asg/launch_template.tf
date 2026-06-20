# ----------------------------
# 起動テンプレート作成
# → AutoScalingでスケールするために起動テンプレートを作成
# ----------------------------
# インスタンス定義指定
resource "aws_launch_template" "ec2_template" {
  iam_instance_profile {
    name = var.iam_instance_profile
  }
  name_prefix            = "${var.common_tags["Env"]}-launch"
  image_id               = var.ec2_instance_define.ami
  instance_type          = var.ec2_instance_define.instance_type
  vpc_security_group_ids = var.vpc_security_group_ids

  tag_specifications {
    resource_type = "instance"
    tags = merge(var.common_tags, {
      Name = "${var.common_tags["Env"]}-launch-template"
    })
  }

  # S3上のrepoを使って閉域環境でmariadbクライアントをインストールのみ、httpdをインストール・起動（NAT不要）
  user_data = base64encode(<<-EOF
#!/bin/bash
set -euxo pipefail

# ログ出力
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

LOCAL_REPO_DIR="/opt/localrepo"
BUCKET_NAME="${var.s3_bucket_name}"

# S3からrepo一式をローカルへ同期
rm -rf $${LOCAL_REPO_DIR}
mkdir -p $${LOCAL_REPO_DIR}
aws s3 sync s3://$${BUCKET_NAME} $${LOCAL_REPO_DIR}

# 既存repoを無効化
mkdir -p /etc/yum.repos.d/backup
find /etc/yum.repos.d -maxdepth 1 -name "*.repo" -exec mv {} /etc/yum.repos.d/backup/ ';'

# ローカルrepo定義
cat > /etc/yum.repos.d/local.repo <<'REPO'
[local]
name=Local Repository
baseurl=file:///opt/localrepo
enabled=1
gpgcheck=0
REPO

# キャッシュ再作成
dnf clean all
dnf makecache --disablerepo="*" --enablerepo="local"

# Apache(httpd)、mariadbクライアント を local repo のみからインストール
dnf install -y httpd mariadb114 --disablerepo="*" --enablerepo="local"

# Apache 起動
systemctl enable httpd
systemctl start httpd

# 動作確認用ページ
cat > /var/www/html/index.html <<HTML
hello from $(hostname)
HTML
EOF
  )
}
