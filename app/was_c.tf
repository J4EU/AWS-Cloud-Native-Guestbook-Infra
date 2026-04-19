resource "aws_instance" "was_c" {
  ami           = data.aws_ami.amazon_linux_2023_arm64.id
  instance_type = var.was_instance_type
  key_name      = "guestbook-was"

  subnet_id              = data.terraform_remote_state.network_link.outputs.private_subnet1_c_id
  availability_zone      = "ap-northeast-2c"
  vpc_security_group_ids = [aws_security_group.was_sg.id]

  associate_public_ip_address = false

  user_data = <<-EOF
    #!/bin/bash
    sudo dnf update -y
    sudo dnf install -y python3-pip
    sudo dnf install -y mariadb114

    sudo pip3 install fastapi uvicorn mysql-connector-python pydantic python-dotenv
  EOF

  tags = {
    Name = "WAS-c"
  }
}
