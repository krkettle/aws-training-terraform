# ------------------------------
# Security Group
# ------------------------------
resource "aws_security_group" "tr_sg" {
  name   = "${var.project}-tr-sg"
  vpc_id = var.vpc_id

  tags = {
    Name    = "${var.project}-tr-sg"
    Project = var.project
  }
}

resource "aws_security_group_rule" "tr_in_http" {
  security_group_id = aws_security_group.tr_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_blocks       = var.source_ip_list
}

resource "aws_security_group_rule" "tr_in_ssh" {
  security_group_id = aws_security_group.tr_sg.id
  type              = "ingress"
  protocol          = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_blocks       = var.source_ip_list
}

resource "aws_security_group_rule" "tr_out_all" {
  security_group_id = aws_security_group.tr_sg.id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}
