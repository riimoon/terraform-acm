variable "ports" {
  type        = list(number)
  description = "list of ports"
  default     = [443, 80, 22]

}

variable "cidr_blocks" {
  type        = list(string)
  description = "list of cidrs"
  default     = ["0.0.0.0/0", "0.0.0.0/0", "98.227.136.153/32"]

}

variable "team" {
  type    = string
  default = "devops"
}

variable "env" {
  type    = string
  default = "dev"

}

variable "app" {
  type    = string
  default = "aws"

}

variable "project" {
  type    = string
  default = "acm"

}

variable "managed_by" {
  type    = string
  default = "terraform"

}

variable "owner" {
  type    = string
  default = "Aru"

}

variable "image_ig" {
  type    = string
  default = "ami-07d9b9ddc6cd8dd30"

}

variable "key_pair" {
  type    = string
  default = "aru@micr"

}

variable "subnet_id" {
  type    = string
  default = "subnet-0ff765291184219f4"

}

variable "min_asg" {
  type    = number
  default = 1

}

variable "max_asg" {
  type    = number
  default = 3

}

variable "desires_asg" {
  type    = number
  default = 1

}

variable "tags" {
  type    = string
  default = "asg-tags"

}

variable "domain" {
  type    = string
  default = "greatlifeglow.click"

}

variable "zone_id" {
  type    = string
  default = "Z00990981OGI1RH6AVMPU"

}

variable "vpc_id" {
  type    = string
  default = "vpc-0642a30a17fed8c2c"

}

variable "list_subnets" {
  type    = list(string)
  default = ["subnet-0ff765291184219f4", "subnet-0218fcaf5267da632"]
}

variable "aws_access_key" {
  default = "put_your_aws_access_key"
}

variable "aws_secret_key" {
  default = "put_your_aws_secret_key"
}