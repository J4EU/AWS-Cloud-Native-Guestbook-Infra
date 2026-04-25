data "terraform_remote_state" "network_state" {
  backend = "local" # 로컬 백엔드 사용

  config = { # 네트워크 리소스 데이터 소스 경로
    path = "../network/terraform.tfstate"
  }
}
