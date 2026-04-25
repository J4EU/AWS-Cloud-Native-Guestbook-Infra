# RDS 인바운드 - WAS의 3306으로 들어오는 트래픽 허용 (WAS -> RDS)
resource "aws_vpc_security_group_ingress_rule" "was_to_rds" {
  description       = "Allow 3306 traffic from WAS"
  security_group_id = data.terraform_remote_state.database.outputs.rds_sg_id

  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.was.id
}
