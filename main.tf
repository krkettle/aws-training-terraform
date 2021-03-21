module "tr_vpc" {
  source  = "./modules/network"
  project = var.project
}

module "tr_sg" {
  source         = "./modules/security"
  project        = var.project
  vpc_id         = module.tr_vpc.vpc_id
  source_ip_list = var.source_ip_list
}

module "tr_ec2" {
  source        = "./modules/training-server"
  project       = var.project
  instance_type = var.instance_type
  subnet_id     = module.tr_vpc.public_subnet_id
  vpc_security_group_ids = [
    module.tr_sg.tr_sg_id
  ]
  policy_attachment_map = {
    MyAmazonS3ReadOnlyAccess = file("./data/iam_policy/MyAmazonS3ReadOnlyAccess.json")
  }
  tr_public_key = file("./data/ssh/training-server.pub")
  tr_user_data  = filebase64("./data/user_data.sh")
}
