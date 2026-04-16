resource "aws_instance" "was_a" {
  ami           = data.aws_ami.amazon_linux_2023_arm64.id
  instance_type = var.was_instance_type
  key_name      = "guestbook-was"

  subnet_id         = aws_subnet.private_subnet1_a.id
  availability_zone = "ap-northeast-2a"
  security_groups   = [aws_security_group.was_sg.id]

  associate_public_ip_address = false

  user_data = <<-EOF
    sudo dnf update -y
    sudo dnf install -y python3-pip
    sudo dnf install -y mariadb114

    sudo pip3 install fastapi uvicorn mysql-connector-python pydantic python-dotenv
  EOF

  tags = {
    Name = "WAS-a"
  }
}
