# NAT 인바운드 - WAS의 모든 트래픽 허용 (WAS -> NAT)
resource "aws_vpc_security_group_ingress_rule" "allow_all_from_was" {
  description       = "Allow traffic from WAS"
  security_group_id = aws_security_group.nat_sg.id

  ip_protocol                  = "-1"
  referenced_security_group_id = aws_security_group.was_sg.id
}

# RDS 인바운드 - WAS의 3306으로 들어오는 트래픽 허용 (WAS -> RDS)
resource "aws_vpc_security_group_ingress_rule" "allow_3306_from_was" {
  description       = "Allow 3306 traffic from WAS"
  security_group_id = data.terraform_remote_state.database_link.outputs.rds_sg_id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.was_sg.id
}

# WAS 인바운드 - 8000 포트로 들어오는 ALB 트래픽 허용
resource "aws_vpc_security_group_ingress_rule" "allow_8000" {
  description       = "Allow traffic from 8000 port"
  security_group_id = aws_security_group.was_sg.id

  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb_sg.id
}
