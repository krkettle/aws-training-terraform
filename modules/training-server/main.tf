# ------------------------------
# AMI
# ------------------------------
data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["self", "amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64-gp2"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
# ------------------------------
# Key Pair
# ------------------------------
resource "aws_key_pair" "tr_public_key" {
  key_name   = "tr_public_key"
  public_key = var.tr_public_key
}

# ------------------------------
# EC2 instance
# ------------------------------
resource "aws_instance" "tr_ec2" {
  ami                         = data.aws_ami.amzn2.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.tr_ec2_profile.name
  vpc_security_group_ids      = var.vpc_security_group_ids
  key_name                    = aws_key_pair.tr_public_key.key_name
  user_data                   = var.tr_user_data

  tags = {
    Name    = "${var.project}-tr-ec2"
    Project = var.project
  }
}

# ------------------------------
# IAM
# ------------------------------
# Instance Profile
resource "aws_iam_instance_profile" "tr_ec2_profile" {
  name = aws_iam_role.tr_iam_role.name
  role = aws_iam_role.tr_iam_role.name
}

# Role
resource "aws_iam_role" "tr_iam_role" {
  name               = "${var.project}-tr-iam-role"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy.json
}

# Policy
data "aws_iam_policy_document" "ec2_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "template_file" "tr_ec2_policy_template" {
  for_each = var.policy_attachment_map
  template = each.value
}

resource "aws_iam_policy" "tr_ec2_policy" {
  for_each = data.template_file.tr_ec2_policy_template
  name     = each.key
  policy   = each.value.rendered

}

# Policy Attachment
resource "aws_iam_role_policy_attachment" "tr_ec2_policy_attach" {
  for_each   = aws_iam_policy.tr_ec2_policy
  role       = aws_iam_role.tr_iam_role.name
  policy_arn = each.value.arn
}
