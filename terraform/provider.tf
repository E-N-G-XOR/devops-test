terraform {
  backend "s3" {
    encrypt = true
    bucket = "lw-candidate-devops-test"
    key    = "terraform/devops/test.tfstate"
    region = "eu-west-1"
    # dynamodb_table = "terraform-state-lock-dynamo"

  }
}

provider "aws" {
  region = "eu-west-1"
}
