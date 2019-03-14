variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "instance_type" {}

variable "subnet_id" {}

variable "security_group_id" {
  type = "list"
}

variable "ami" {
  type = "map"

  default = {
    "client" = "ami-06c350abb0d40236f"
    "server" = "ami-0085f11818f401bdf"
  }
}
