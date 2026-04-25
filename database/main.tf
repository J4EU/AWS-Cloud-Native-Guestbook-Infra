resource "aws_security_group" "rds" {
  name        = "guestbook-rds-sg"
  description = "Allow traffic from WAS SG"
  vpc_id      = data.terraform_remote_state.network_state.outputs.vpc_id

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "all_traffic_rds" {
  security_group_id = aws_security_group.rds.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# RDS 서브넷 그룹
resource "aws_db_subnet_group" "this" {
  name        = "guestbook-rds-subnet-group"
  description = "RDS subnet group"

  # 프라이빗 서브넷 (RDS) 2개 이상
  subnet_ids = [
    data.terraform_remote_state.network_state.outputs.rds_subnet_a_id,
    data.terraform_remote_state.network_state.outputs.rds_subnet_c_id
  ]

  tags = {
    Name = "guestbook-rds-subnet-group"
  }
}

# RDS 파라미터 그룹
resource "aws_db_parameter_group" "this" {
  name        = "guestbook-rds-pg"
  description = "RDS parameter group"
  family      = "mariadb11.8" # MariaDB 11.8 전용 파라미터 그룹

  parameter {
    name  = "character_set_server" # 서버 기본 문자셋
    value = "utf8mb4"              # 이모지까지 지원
  }

  parameter {
    name  = "character_set_client" # 클라이언트 연결 문자셋
    value = "utf8mb4"
  }

  tags = {
    Name = "guestbook-rds-pg"
  }
}

resource "aws_db_instance" "rds" {
  identifier        = "guestbook-rds-instance"
  allocated_storage = 20 # 20GB 스토리지
  engine            = "mariadb"
  engine_version    = "11.8"
  instance_class    = "db.t3.micro"
  port              = 3306

  db_name  = var.db_name
  username = var.username
  password = var.rds_password

  db_subnet_group_name = aws_db_subnet_group.this.name
  parameter_group_name = aws_db_parameter_group.this.name

  vpc_security_group_ids = [aws_security_group.rds.id]

  skip_final_snapshot = true  # 삭제시 스냅샷 생략 (개발용)
  multi_az            = false # 멀티 리전 사용 안 함 (개발용)

  tags = {
    Name = "guestbook-rds-instance"
  }
}
