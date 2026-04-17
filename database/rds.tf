# 데이터베이스 서브넷 그룹 (가용 영역이 다른 서브넷 2개 이상)
resource "aws_db_subnet_group" "db_sn_group" {
  name       = "rds-db-subnet-group"
  subnet_ids = [data.terraform_remote_state.core_link.outputs.private_subnet2_a_id, data.terraform_remote_state.core_link.outputs.private_subnet2_c_id]

  tags = {
    Name = "DB Subnet Group"
  }
}

resource "aws_db_parameter_group" "db_pg" {
  name   = "rds-pg"
  family = "mariadb11.8"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
}

resource "aws_db_instance" "rds" {
  allocated_storage = 20
  engine            = "mariadb"
  engine_version    = "11.8"
  instance_class    = "db.t3.micro"

  db_name  = "guestbook"
  username = "admin"
  password = var.rds_password

  db_subnet_group_name = aws_db_subnet_group.db_sn_group.name
  parameter_group_name = aws_db_parameter_group.db_pg.name

  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  skip_final_snapshot = true
  multi_az            = true
}
