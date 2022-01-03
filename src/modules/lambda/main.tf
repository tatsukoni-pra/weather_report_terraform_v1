###############################################
# Security Group
###############################################
resource "aws_security_group" "lambda_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-lambda-sg"
  description = "${var.service_name}-lambda-sg"

  tags = {
    Name = "${var.service_name}-lambda-sg"
  }
}

resource "aws_security_group_rule" "lambda_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.lambda_sg.id
  depends_on        = [aws_security_group.lambda_sg]
}
