variable "project" {
  type = string
}

variable "availability_zone" {
  type    = string
  default = "ap-northeast-1a"
}

variable "vpc_cidr_block" {
  type    = string
  default = "192.168.0.0/20"
}

variable "subnet_cidr_block" {
  type    = string
  default = "192.168.1.0/24"
}
