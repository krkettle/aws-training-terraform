#!/bin/bash
# ユーザデータのログを/var/log/user-data.logに出力
exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# 環境変数(自由に変更可能)
PROJECT_NAME="aws-training"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
BUCKET_NAME="${PROJECT_NAME}-${AWS_ACCOUNT_ID}"
GIT_URL="https://github.com/krkettle/docker-kaggle.git"

yum update -y
yum install -y git dos2unix

# Dockerのインストール
amazon-linux-extras install docker
service docker start
usermod -aG docker ec2-user

# Docker Composeのインストール
curl -L https://github.com/docker/compose/releases/download/1.16.1/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# サンプルコードのアップロード
git clone $GIT_URL sample-code
chmod 777 sample-code

# 研修者用ディレクトリのセットアップ
aws s3 cp s3://${BUCKET_NAME}/users/user_list.txt .
dos2unix user_list.txt
mkdir /home/ec2-user/tr_users_keys
readline() {
  IFS= read -r "$1" || eval "[ \"\${$1}\" ] &&:"
}
while readline user; do
  # ユーザ作成
  useradd $user

  # ユーザ毎にキーペア作成
  command='
  ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa  -P "";
  chmod 700 ~/.ssh;
  touch ~/.ssh/authorized_keys;
  chmod 600 ~/.ssh/authorized_keys;
  cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys;
  '
  su - $user -c "$command"
  cp "/home/${user}/.ssh/id_rsa" "/home/ec2-user/tr_users_keys/${user}"
  chmod 444 "/home/ec2-user/tr_users_keys/${user}"

  # サンプルコードを配置
  cp -r sample-code "/home/${user}/sample-code"
done <user_list.txt
echo "Done at $(date '+%Y/%m/%d %H:%M:%S')" >/opt/status.txt
