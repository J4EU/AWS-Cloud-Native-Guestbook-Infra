# WAS 보안 그룹
resource "aws_security_group" "was" {
  name   = "was-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "was_sg"
  }
}

# WAS 인바운드 - 8000 포트로 들어오는 ALB 트래픽 허용
resource "aws_vpc_security_group_ingress_rule" "alb_to_was_8000" {
  description       = "Allow traffic from 8000 port"
  security_group_id = aws_security_group.was.id

  from_port                    = 8000
  to_port                      = 8000
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.alb.id
}

# WAS 인바운드 - 22 포트로 들어오는 NAT 트래픽 허용
resource "aws_vpc_security_group_ingress_rule" "nat_to_was_ssh" {
  description       = "Allow SSH traffic from NAT Instance"
  security_group_id = aws_security_group.was.id

  from_port                    = 22
  to_port                      = 22
  ip_protocol                  = "tcp"
  referenced_security_group_id = aws_security_group.nat.id
}

# WAS 아웃바운드
resource "aws_vpc_security_group_egress_rule" "was_to_all" {
  security_group_id = aws_security_group.was.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# ASG 시작 템플릿
resource "aws_launch_template" "was" {
  name_prefix   = "guestbook-was-lt-"
  image_id      = var.my_ami
  instance_type = var.was_instance_type
  key_name      = "guestbook-was"

  vpc_security_group_ids = [aws_security_group.was.id]

  user_data = base64encode(<<-EOF
        #!/bin/bash

        cd /home/ec2-user
        
        RDS_ADDR=$(echo "${data.terraform_remote_state.database.outputs.rds_endpoint}" | cut -d':' -f1)
        echo "DB_HOST=$RDS_ADDR" > .env
        echo "DB_USER=${var.username}" >> .env
        echo "DB_PASS=${var.rds_password}" >> .env
        echo "DB_NAME=${var.db_name}" >> .env

        nohup uvicorn main:app --host 0.0.0.0 --port 8000 > was.log 2>&1 &
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "guestbook-was-asg"
    }
  }
}

# ASG
resource "aws_autoscaling_group" "was" {
  name             = "guestbook-was-asg"
  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  vpc_zone_identifier = [
    data.terraform_remote_state.network.outputs.was_subnet_a_id,
    data.terraform_remote_state.network.outputs.was_subnet_c_id
  ]

  # 시작 템플릿 연결
  launch_template {
    id      = aws_launch_template.was.id
    version = "$Latest"
  }

  # ALB 타겟 그룹 연결
  target_group_arns = [aws_lb_target_group.was.arn]

  # 상태 확인 설정 (ALB)
  health_check_type         = "ELB"
  health_check_grace_period = 300
}

# CPU 스케일링 정책
resource "aws_autoscaling_policy" "was_cpu" {
  name                   = "was-cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.was.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
