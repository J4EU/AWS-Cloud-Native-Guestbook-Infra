# NAT 보안 그룹
resource "aws_security_group" "nat" {
  name   = "nat-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "nat_sg"
  }
}

# NAT 인바운드 - SSH(Only My IP)
resource "aws_vpc_security_group_ingress_rule" "my_ip_to_nat_ssh" {
  description       = "Allow SSH from only My IP"
  security_group_id = aws_security_group.nat.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = "${var.my_ip}/32"
}

# NAT 인바운드 - WAS의 모든 트래픽 허용 (WAS -> NAT)
resource "aws_vpc_security_group_ingress_rule" "was_to_nat_all" {
  description       = "Allow traffic from WAS"
  security_group_id = aws_security_group.nat.id

  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.was.id
}

# NAT 아웃바운드
resource "aws_vpc_security_group_egress_rule" "nat_to_all" {
  security_group_id = aws_security_group.nat.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_instance" "nat_az_a" {
  ami           = data.aws_ami.amazon_linux_2023_arm64.id
  instance_type = "t4g.nano" # 비용 절감을 위해 t4g.nano(ARM) 사용. NAT는 X86 호환성 덜 필요함
  key_name      = "guestbook-nat"

  subnet_id              = data.terraform_remote_state.network.outputs.nat_subnet_a_id
  availability_zone      = "ap-northeast-2a"
  vpc_security_group_ids = [aws_security_group.nat.id]

  # "다른 EC2의 트래픽도 중계하겠다"라는 설정 (NAT/VPN용)
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
    Name = "Guestbook-NAT-a"
  }
}

resource "aws_instance" "nat_az_c" {
  ami           = data.aws_ami.amazon_linux_2023_arm64.id
  instance_type = "t4g.nano" # 비용 절감을 위해 t4g.nano(ARM) 사용. NAT는 X86 호환성 덜 필요함
  key_name      = "guestbook-nat"

  subnet_id              = data.terraform_remote_state.network.outputs.nat_subnet_c_id
  availability_zone      = "ap-northeast-2c"
  vpc_security_group_ids = [aws_security_group.nat.id]

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

resource "aws_eip" "nat_a_eip" {
  instance = aws_instance.nat_az_a.id

  # EIP를 특정 VPC 안에서 사용하기 위해 할당 받겠다라는 선언
  domain = "vpc"

  tags = {
    Name = "nat-a-eip"
  }
}

resource "aws_eip" "nat_c_eip" {
  instance = aws_instance.nat_az_c.id

  # EIP를 특정 VPC 안에서 사용하기 위해 할당 받겠다라는 선언
  domain = "vpc"

  tags = {
    Name = "nat-c-eip"
  }
}

# 프라이빗 서브넷 라우팅 테이블 - 라우팅 규칙 (NAT 인스턴스의 ENI로 전송)
resource "aws_route" "was_to_nat_a" {
  route_table_id         = data.terraform_remote_state.network.outputs.was_private_a_rt_id
  destination_cidr_block = "0.0.0.0/0"

  # 패킷을 인스턴스 본체로 보내는 게 아니라, NAT Instance (AZ-a)의 ENI(네트워크 인터페이스=NIC)로 보낸다
  network_interface_id = aws_instance.nat_az_a.primary_network_interface_id
}

resource "aws_route" "was_to_nat_c" {
  route_table_id         = data.terraform_remote_state.network.outputs.was_private_c_rt_id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.nat_az_c.primary_network_interface_id
}
