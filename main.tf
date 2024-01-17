resource "aws_security_group" "main" {
  name        = "${var.name}-${var.env}-sg"
  description = "${var.name}-${var.env}-sg"
  vpc_id      = var.vpc_id

  ingress {
    description = "alb"
    from_port   = var.app_port
    to_port     = var.app_port
    protocol    = "tcp"
    cidr_blocks = var.allow_app_cidr
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  tags = merge(var.tags, { Name : "${env}-${component}-sg" })
}

resource "aws_lb" "main" {
  name               = "${var.env}-alb-${var.name}"
  internal           = var.internal
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = var.subnets
  enable_deletion_protection = true
  tags =merge(var.tags, { Name : "${env}-alb-${component}" })
}


resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  protocol          = http
  port = 80
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "unauthorized"
      status_code  = "403"
    }
  }
}