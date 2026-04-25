terraform {
  required_providers { # 필수 프로바이더 설정
    aws = {
      source  = "hashicorp/aws" # AWS 프로바이더 소스
      version = "~> 6.41"       # AWS 프로바이더 버전 제한 6.41 이상
    }
  }
  required_version = ">= 1.14" # Terraform 버전 제한 1.14 이상
}

provider "aws" {
  region = "ap-northeast-2" # 리전 설정
}
