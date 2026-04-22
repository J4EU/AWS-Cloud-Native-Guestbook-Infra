# ASG 시작 템플릿
resource "aws_launch_template" "was_lt" {
  name_prefix   = "guestbook-was-lt-"
  image_id      = var.my_ami
  instance_type = var.was_instance_type
  key_name      = "guestbook-was"

  vpc_security_group_ids = [aws_security_group.was_sg.id]

  user_data = base64encode(<<-EOF
        #!/bin/bash

        cd /home/ec2-user
        
        RDS_ADDR=$(echo "${data.terraform_remote_state.database_link.outputs.rds_endpoint}" | cut -d':' -f1)
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
      Name = "Guestbook-WAS-ASG"
    }
  }
}

resource "aws_autoscaling_group" "was_asg" {
  name             = "guestbook-was-asg"
  desired_capacity = 2
  max_size         = 4
  min_size         = 2

  vpc_zone_identifier = [
    data.terraform_remote_state.network_link.outputs.private_subnet1_a_id,
    data.terraform_remote_state.network_link.outputs.private_subnet1_c_id
  ]

  # 시작 템플릿 연결
  launch_template {
    id      = aws_launch_template.was_lt.id
    version = "$Latest"
  }

  # ALB 타겟 그룹 연결
  target_group_arns = [aws_lb_target_group.was_tg.arn]

  # 상태 확인 설정 (ALB)
  health_check_type         = "ELB"
  health_check_grace_period = 300
}

resource "aws_autoscaling_policy" "was_cpu_policy" {
  name                   = "was-cpu-scaling-policy"
  autoscaling_group_name = aws_autoscaling_group.was_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}
