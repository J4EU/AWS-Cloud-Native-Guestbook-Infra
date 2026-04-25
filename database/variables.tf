# 데이터베이스 이름
variable "db_name" {
  description = "DB name"
  type        = string
}

# RDS 사용자 이름
variable "username" {
  description = "RDS username"
  type        = string
  sensitive   = true
}

# RDS 사용자 비밀번호
variable "rds_password" {
  description = "RDS account password"
  type        = string
  sensitive   = true
}
