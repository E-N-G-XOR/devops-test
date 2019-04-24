terraform {
  backend "s3" {
    bucket = "lw-candidate-test"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}
