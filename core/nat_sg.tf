# NAT 보안 그룹
resource "aws_security_group" "nat_sg" {
  name   = "nat-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "NAT-SG"
  }
}

# NAT 인바운드 - SSH(Only My IP)
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_MyIP" {
  description       = "Allow SSH from only My IP"
  security_group_id = aws_security_group.nat_sg.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  cidr_ipv4   = "${var.my_ip}/32"
}

# NAT 인바운드 - WAS의 모든 트래픽 허용 -> /app/network_rules.tf에 정의됨

# NAT 아웃바운드
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_nat" {
  security_group_id = aws_security_group.nat_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
