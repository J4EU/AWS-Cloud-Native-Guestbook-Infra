# WAS 보안 그룹
resource "aws_security_group" "was_sg" {
  name   = "was-sg"
  vpc_id = data.terraform_remote_state.network_link.outputs.vpc_id

  tags = {
    Name = "WAS-SG"
  }
}

# WAS 인바운드 - 8000 포트로 들어오는 ALB 트래픽 허용 - ../network_rules.tf에 정의됨

# WAS 인바운드 - 22 포트로 들어오는 NAT 트래픽 허용
resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_nat" {
  description       = "Allow SSH traffic from NAT Instance"
  security_group_id = aws_security_group.was_sg.id

  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.nat_sg.id
}

# WAS 아웃바운드
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_was" {
  security_group_id = aws_security_group.was_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
