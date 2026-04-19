data "terraform_remote_state" "network_link" {
  backend = "local"

  config = {
    path = "../network/terraform.tfstate"
  }
}
