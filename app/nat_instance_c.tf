resource "aws_instance" "guestbook_nat_instance_c" {
  ami           = data.aws_ami.amazon_linux_2023_arm64.id
  instance_type = "t4g.nano" # 비용 절감을 위해 t4g.nano(ARM) 사용. NAT는 X86 호환성 덜 필요함
  key_name      = "guestbook-nat"

  subnet_id              = data.terraform_remote_state.network_link.outputs.public_subnet1_c_id
  availability_zone      = "ap-northeast-2c"
  vpc_security_group_ids = [aws_security_group.nat_sg.id]

  source_dest_check = false

  user_data = <<-EOF
    #!/bin/bash
    dnf install iptables-services -y

    sysctl -w net.ipv4.ip_forward=1
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

    iptables -F
    iptables -P FORWARD ACCEPT

    IFACE=$(ip route | grep default | awk '{print $5}')
    iptables -t nat -A POSTROUTING -o $IFACE -j MASQUERADE
    EOF

  tags = {
    Name = "Guestbook-NAT-c"
  }
}

resource "aws_eip" "guestbook_nat2_eip" {
  instance = aws_instance.guestbook_nat_instance_c.id

  # EIP를 특정 VPC 안에서 사용하기 위해 할당 받겠다라는 선언
  domain = "vpc"

  tags = {
    Name = "guestbook-nat-c-eip"
  }
}

resource "aws_route" "was_nat_route_c" {
  route_table_id         = data.terraform_remote_state.network_link.outputs.private_c_rt_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.guestbook_nat_instance_c.primary_network_interface_id
}
