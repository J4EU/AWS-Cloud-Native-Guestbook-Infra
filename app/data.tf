# L1 (Core Outputs 참조)
data "terraform_remote_state" "core_link" {
  backend = "local"

  config = {
    path = "../core/terraform.tfstate"
  }
}

# L2 (Database Outputs 참조)
data "terraform_remote_state" "database_link" {
  backend = "local"

  config = {
    path = "../database/terraform.tfstate"
  }
}

data "aws_ami" "amazon_linux_2023_arm64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-kernel-6.1-arm64"]
  }

  filter {
    name   = "architecture"
    values = ["arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
