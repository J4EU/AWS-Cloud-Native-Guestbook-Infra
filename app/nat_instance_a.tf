resource "aws_instance" "guestbook_nat_instance_a" {
  ami           = data.aws_ami.amazon_linux_2023_arm64.id
  instance_type = "t4g.nano" # 비용 절감을 위해 t4g.nano(ARM) 사용. NAT는 X86 호환성 덜 필요함
  key_name      = "guestbook-nat"

  subnet_id              = data.terraform_remote_state.network_link.outputs.public_subnet1_a_id
  availability_zone      = "ap-northeast-2a"
  vpc_security_group_ids = [aws_security_group.nat_sg.id]

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

resource "aws_eip" "guestbook_nat1_eip" {
  instance = aws_instance.guestbook_nat_instance_a.id

  # EIP를 특정 VPC 안에서 사용하기 위해 할당 받겠다라는 선언
  domain = "vpc"

  tags = {
    Name = "guestbook-nat-a-eip"
  }
}

# 프라이빗 서브넷 라우팅 테이블 - 라우팅 규칙 (NAT 인스턴스의 ENI로 전송)
resource "aws_route" "was_nat_route_a" {
  route_table_id         = data.terraform_remote_state.network_link.outputs.private_a_rt_id
  destination_cidr_block = "0.0.0.0/0"

  # 패킷을 인스턴스 본체로 보내는 게 아니라, NAT Instance (AZ-a)의 ENI(네트워크 인터페이스=NIC)로 보낸다
  network_interface_id = aws_instance.guestbook_nat_instance_a.primary_network_interface_id
}
