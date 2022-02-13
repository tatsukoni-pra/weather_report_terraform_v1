###############################################
# ECS Resource
###############################################
resource "aws_ecs_cluster" "ecs_bitcoin_cluster" {
  name = "${var.service_name}-ecs-bitcoin-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "${var.service_name}-ecs-bitcoin-cluster"
  }
}

resource "aws_ecs_task_definition" "bitcoin_task" {
  family                   = "${var.service_name}-bitcoin-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.ecs_task_role.arn
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  cpu                      = 256
  memory                   = 512
  container_definitions = templatefile("../files/task/bitcoin_task_definitions.json", {
    account_id = var.account_id
  })
}

resource "aws_ecs_service" "bitcoin_service" {
  cluster                            = aws_ecs_cluster.ecs_bitcoin_cluster.id
  task_definition                    = aws_ecs_task_definition.bitcoin_task.arn
  desired_count                      = 1
  launch_type                        = "FARGATE"
  name                               = "${var.service_name}-bitcoin-service"
  enable_execute_command             = true
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  lifecycle {
    ignore_changes = [
      desired_count,
      task_definition
    ]
  }

  network_configuration {
    subnets          = var.public_sub
    security_groups  = [aws_security_group.ecs_bitcoin_sg.id]
    assign_public_ip = true # trueにしないと起動時にSSM値取得ができない。要確認
  }
}

###############################################
# IAM
###############################################
resource "aws_iam_role" "ecs_task_role" {
  name               = "${var.service_name}-ecs-task-exec-role"
  assume_role_policy = file("../files/role/ecs_task_role.json")

  tags = {
    Name = "${var.service_name}-ecs-task-exec-role"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment_task" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_policy_attachment_ssm" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy" "ecs_task_policy" {
  name = "${var.service_name}-ecs-task-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = file("../files/policy/ecs_task_policy.json")
}

###############################################
# Cloud Watch
###############################################
resource "aws_cloudwatch_log_group" "ecs_bitcoin_task" {
  name = "/ecs/bitcoin-task"

  tags = {
    Name = "${var.service_name}-ecs-bitcoin-task-cwl"
  }
}

###############################################
# Security Group
###############################################
resource "aws_security_group" "ecs_bitcoin_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.service_name}-ecs-bitcoin-sg"
  description = "${var.service_name}-ecs-bitcoin-sg"

  tags = {
    Name = "${var.service_name}-ecs-bitcoin-sg"
  }
}

resource "aws_security_group_rule" "ecs_bitcoin_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_bitcoin_sg.id
  depends_on        = [aws_security_group.ecs_bitcoin_sg]
}
