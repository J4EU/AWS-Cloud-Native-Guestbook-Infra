resource "aws_instance" "guestbook_nat_instance_a" {
  ami           = data.aws_ami.amazon_linux_2023_arm64.id
  instance_type = "t4g.nano" # 비용 절감을 위해 t4g.nano(ARM) 사용. NAT는 X86 호환성 덜 필요함
  key_name      = "guestbook-nat"

  subnet_id              = aws_subnet.public_subnet1_a.id
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
