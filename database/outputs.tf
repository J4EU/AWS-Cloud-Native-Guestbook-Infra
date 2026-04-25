# RDS 엔드포인트
output "rds_endpoint" {
  value = aws_db_instance.rds.endpoint
}

# RDS 보안 그룹 ID
output "rds_sg_id" {
  value = aws_security_group.rds.id
}
