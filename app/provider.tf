terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.41"
    }
  }
  required_version = ">= 1.14"
}

provider "aws" {
  region = "ap-northeast-2"
}
