variable "name" {
  default = "candidate-test"
}

variable "vpc_id" {
  default = ""
}

variable "subnets" {
  default = []
}

variable "instance_type" {
  default = "t2.micro"
}
