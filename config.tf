terraform {
  required_providers {
    aws = {
      version = "~> 4.63.0"
      source = "hashicorp/aws"
    }
  }
  required_version = "~> 1.4.5"
}

provider "aws" {
  alias  = "euw3"
  region = "eu-west-3"
}

module "improved_couscous" {
  source       = "./modules/improved_couscous"
  providers = {
    aws = aws.euw3
  }
}
