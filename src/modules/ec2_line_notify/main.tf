###############################################
# EC2 Resource
###############################################
resource "aws_instance" "ec2_line_notify" {
  ami                    = local.ec2_instance_values.ami
  instance_type          = local.ec2_instance_values.instance_type
  subnet_id              = var.public_sub_id
  vpc_security_group_ids = [aws_security_group.ec2_line_notify_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_line_notify_role_profile.id
  user_data              = file("../files/user_data/ec2_line_notify_user_data.sh")

  tags = {
    Name = "${var.service_name}"
  }
}

resource "aws_iam_instance_profile" "ec2_line_notify_role_profile" {
  name = "ec2_line_notify_role_profile"
  role = aws_iam_role.ec2_line_notify_role.name
}

###############################################
# EC2 Security Group Resource
###############################################
resource "aws_security_group" "ec2_line_notify_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-sg"
  description = "${var.service_name}-sg"

  tags = {
    Name = "${var.service_name}-sg"
  }
}

resource "aws_security_group_rule" "ec2_line_notify_sg_ingress" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2_line_notify_sg.id
  depends_on        = [aws_security_group.ec2_line_notify_sg]
  cidr_blocks       = [var.vpc_cidr_block]
}

resource "aws_security_group_rule" "ec2_line_notify_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_line_notify_sg.id
  depends_on        = [aws_security_group.ec2_line_notify_sg]
}

###############################################
# ALB Resource
###############################################
resource "aws_lb" "ec2_line_notify_alb" {
  name               = "${var.service_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ec2_line_notify_alb_sg.id]
  subnets = [
    var.public_sub_id,
    var.public_sub_1c_id
  ]

  tags = {
    Name = "${var.service_name}-alb"
  }
}

resource "aws_lb_listener" "ec2_line_notify_alb" {
  load_balancer_arn = aws_lb.ec2_line_notify_alb.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ec2_line_notify_alb.arn
  }

  tags = {
    Name = "${var.service_name}-alb-listener"
  }
}

// HTTPアクセス時、HTTPSにリダイレクトさせる
resource "aws_lb_listener" "ec2_line_notify_alb_http" {
  load_balancer_arn = aws_lb.ec2_line_notify_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  tags = {
    Name = "${var.service_name}-alb-listener-http"
  }
}

resource "aws_lb_target_group" "ec2_line_notify_alb" {
  name     = "${var.service_name}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
  health_check {
    path = "/ping.html"
  }

  tags = {
    Name = "${var.service_name}-alb-tg"
  }
}

resource "aws_lb_target_group_attachment" "ec2_line_notify_alb" {
  target_group_arn = aws_lb_target_group.ec2_line_notify_alb.arn
  target_id        = aws_instance.ec2_line_notify.id
  port             = 80
}

###############################################
# ALB Security Group Resource
###############################################
resource "aws_security_group" "ec2_line_notify_alb_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-alb-sg"
  description = "${var.service_name}-alb-sg"

  tags = {
    Name = "${var.service_name}-alb-sg"
  }
}

resource "aws_security_group_rule" "ec2_line_notify_alb_sg_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2_line_notify_alb_sg.id
  depends_on        = [aws_security_group.ec2_line_notify_alb_sg]
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ec2_line_notify_alb_sg_ingress_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.ec2_line_notify_alb_sg.id
  depends_on        = [aws_security_group.ec2_line_notify_alb_sg]
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ec2_line_notify_alb_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2_line_notify_alb_sg.id
  depends_on        = [aws_security_group.ec2_line_notify_alb_sg]
}

###############################################
# Route53 Resource
###############################################
resource "aws_route53_record" "ec2_line_notify_role" {
  zone_id = var.zone_id
  name    = "ec2-line-notify-demo.${var.domain}"
  type    = "A"
  alias {
    name                   = aws_lb.ec2_line_notify_alb.dns_name
    zone_id                = aws_lb.ec2_line_notify_alb.zone_id
    evaluate_target_health = false
  }
}

###############################################
# IAM Resource
###############################################
resource "aws_iam_role" "ec2_line_notify_role" {
  name               = "${var.service_name}-role"
  assume_role_policy = file("../files/role/ec2_line_notify_role.json")

  tags = {
    Name = "${var.service_name}-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment_task" {
  role       = aws_iam_role.ec2_line_notify_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

##############################################################
# VPC Endpoint Resource
# SSM接続用のVPCエンドポイントを作成する
# ※ modules/vpc_endpoint/ で作成済の場合は、ここはコメントアウトする
##############################################################
resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [var.public_sub_id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]

  tags = {
    Name = "ssm-endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [var.public_sub_id]
  security_group_ids  = [aws_security_group.endpoint_sg.id]

  tags = {
    Name = "ssmmessages-endpoint"
  }
}

resource "aws_security_group" "endpoint_sg" {
  vpc_id      = var.vpc_id
  name        = "endpoints-sg"
  description = "endpoints-sg"

  tags = {
    Name = "endpoints-sg"
  }
}

resource "aws_security_group_rule" "endpoint_sg_ingress" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.endpoint_sg.id
  depends_on        = [aws_security_group.endpoint_sg]
  cidr_blocks       = [var.vpc_cidr_block]
}

resource "aws_security_group_rule" "endpoint_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.endpoint_sg.id
  depends_on        = [aws_security_group.endpoint_sg]
}
