# 데이터베이스 서브넷 그룹 (가용 영역이 다른 프라이빗 서브넷 2개 이상)
resource "aws_db_subnet_group" "db_sn_group" {
  name = "db-subnet-group"
  subnet_ids = [
    data.terraform_remote_state.network_link.outputs.private_subnet2_a_id,
    data.terraform_remote_state.network_link.outputs.private_subnet2_c_id
  ]

  tags = {
    Name = "db-subnet-group"
  }
}

# 파라미터 그룹
resource "aws_db_parameter_group" "db_pg" {
  name   = "rds-pg"
  family = "mariadb11.8" # MariaDB 11.8 전용 파라미터 그룹

  parameter {
    name  = "character_set_server" # 서버 기본 문자셋
    value = "utf8mb4"              # 이모지까지 지원
  }

  parameter {
    name  = "character_set_client" # 클라이언트 연결 문자셋
    value = "utf8mb4"
  }
}

resource "aws_db_instance" "rds" {
  identifier        = "guestbook-rds"
  allocated_storage = 20
  engine            = "mariadb"
  engine_version    = "11.8"
  instance_class    = "db.t3.micro"

  db_name  = var.db_name
  username = var.username
  password = var.rds_password

  db_subnet_group_name = aws_db_subnet_group.db_sn_group.name
  parameter_group_name = aws_db_parameter_group.db_pg.name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true  # 삭제시 스냅샷 생략 (개발용)
  multi_az            = false # 멀티 리전
}
