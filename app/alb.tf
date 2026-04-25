# ALB 보안 그룹
resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id

  tags = {
    Name = "alb_sg"
  }
}

# ALB 인바운드 - 80(HTTP) 포트로 들어오는 모든 트래픽 허용
resource "aws_vpc_security_group_ingress_rule" "http_to_alb" {
  description       = "Allow 80 traffic"
  security_group_id = aws_security_group.alb.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

# ALB 인바운드 - 443(HTTPS) 포트로 들어오는 모든 트래픽 허용
resource "aws_vpc_security_group_ingress_rule" "https_to_alb" {
  description       = "Allow 443 traffic"
  security_group_id = aws_security_group.alb.id

  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

# ALB 아웃바운드
resource "aws_vpc_security_group_egress_rule" "alb_to_all" {
  security_group_id = aws_security_group.alb.id

  ip_protocol = "-1"
  cidr_ipv4   = "0.0.0.0/0"
}

# ALB 본체
resource "aws_lb" "alb" {
  name               = "guestbook-alb"
  internal           = false # 인터넷에 공개되는 external ALB
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]

  # 퍼블릭 서브넷, 2개 이상 다른 AZ에 걸치도록
  subnets = [
    data.terraform_remote_state.network.outputs.nat_subnet_a_id,
    data.terraform_remote_state.network.outputs.nat_subnet_c_id
  ]

  tags = {
    Name = "guestbook-alb"
  }
}

# 타겟 그룹
resource "aws_lb_target_group" "was" {
  name     = "was-tg"
  port     = 8000
  protocol = "HTTP"
  vpc_id   = data.terraform_remote_state.network.outputs.vpc_id

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
    target_group_arn = aws_lb_target_group.was.arn
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
