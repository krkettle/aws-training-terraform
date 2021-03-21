variable "project" {
  type = string
}

variable "region" {
  type    = string
  default = "ap-northeast-1"
}

variable "source_ip_list" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}
