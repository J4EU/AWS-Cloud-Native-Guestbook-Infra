# ALB 보안 그룹
resource "aws_security_group" "alb_sg" {
  name   = "alb-sg"
  vpc_id = data.terraform_remote_state.network_link.outputs.vpc_id

  tags = {
    Name = "ALB-SG"
  }
}

# ALB 인바운드 - 80(HTTP) 포트로 들어오는 모든 트래픽 허용
resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  description       = "Allow 80 traffic"
  security_group_id = aws_security_group.alb_sg.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

# ALB 인바운드 - 443(HTTPS) 포트로 들어오는 모든 트래픽 허용
resource "aws_vpc_security_group_ingress_rule" "allow_https" {
  description       = "Allow 443 traffic"
  security_group_id = aws_security_group.alb_sg.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

# ALB 아웃바운드
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_alb" {
  security_group_id = aws_security_group.alb_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
