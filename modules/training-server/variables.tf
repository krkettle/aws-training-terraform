variable "project" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}

variable "subnet_id" {
  type = string
}

variable "tr_public_key" {
  type = string
}

variable "tr_user_data" {
  type = string
}

variable "policy_attachment_map" {
  type    = map(string)
  default = {}
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
