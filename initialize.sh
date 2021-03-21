#!/bin/bash
PROJECT_NAME="aws-training"
PROXY_IP="0.0.0.0/0"

# 研修用EC2インスタンス用のキーペアを作成
SSH_DIR="data/ssh"
mkdir -p $SSH_DIR
ssh-keygen -t rsa -b 4096 -f "${SSH_DIR}/training-server" -P ""
chmod 400 "${SSH_DIR}/training-server"

# tfstate用のS3バケットを作成
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query 'Account')
BUCKET_NAME="${PROJECT_NAME}-${AWS_ACCOUNT_ID}"
aws s3 mb "s3://${BUCKET_NAME}"
aws s3api put-public-access-block --bucket $BUCKET_NAME --public-access-block-configuration "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

#terraform.tfvarsを作成
cat <<EOS >terraform.tfvars
project = "${PROJECT_NAME}"
source_ip_list = [
  "${PROXY_IP}"
]
EOS

#terraform.backend
cat <<EOS >backend.tfvars
bucket  = "${BUCKET_NAME}"
key     = "terraform.tfstate"
region  = "ap-northeast-1"
EOS

# terraformの初期設定
terraform init --backend-config=backend.tfvars

# 研修者ユーザ名のリストをS3にアップロード
aws s3 cp data/users/user_list.txt "s3://${BUCKET_NAME}/users/user_list.txt"
