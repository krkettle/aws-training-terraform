variable "project" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "source_ip_list" {
  type    = list(string)
  default = ["0.0.0.0/0"]
}
