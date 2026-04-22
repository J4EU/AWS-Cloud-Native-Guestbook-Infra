# ALB 본체
resource "aws_lb" "alb" {
  name               = "guestbook-alb"
  internal           = false # 인터넷에 공개되는 external ALB
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb_sg.id]

  # 퍼블릭 서브넷, 2개 이상 다른 AZ에 걸치도록
  subnets = [
    data.terraform_remote_state.network_link.outputs.public_subnet1_a_id,
    data.terraform_remote_state.network_link.outputs.public_subnet1_c_id
  ]

  tags = {
    Name = "guestbook-ALB"
  }
}

# 타겟 그룹
resource "aws_lb_target_group" "was_tg" {
  name     = "was-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network_link.outputs.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }

  tags = {
    Name = "was-tg"
  }
}

# 리스너
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.was_tg.arn
  }
}

# Attachment - WAS-a
# resource "aws_lb_target_group_attachment" "was_a" {
#   target_group_arn = aws_lb_target_group.was_tg.arn
#   target_id        = aws_instance.was_a.id
#   port             = 8000
# }

# # Attachment - WAS-c
# resource "aws_lb_target_group_attachment" "was_c" {
#   target_group_arn = aws_lb_target_group.was_tg.arn
#   target_id        = aws_instance.was_c.id
#   port             = 8000
# }

# output
output "alb_dns_name" {
  description = "ALB DNS address"
  value       = aws_lb.alb.dns_name
}
