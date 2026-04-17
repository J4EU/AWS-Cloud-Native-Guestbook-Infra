# RDS 보안 그룹
resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = data.terraform_remote_state.core_link.outputs.vpc_id

  tags = {
    Name = "RDS-SG"
  }
}

# RDS 인바운드 - WAS의 3306으로 들어오는 트래픽 허용 - /app/network_rules.tf에 정의됨

# RDS 아웃바운드
resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_rds" {
  security_group_id = aws_security_group.rds_sg.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}
