resource "aws_db_proxy" "rds_proxy" {
  name                   = "${var.service_name}-rds-proxy"
  debug_logging          = false
  engine_family          = local.engine_family
  idle_client_timeout    = 1800
  require_tls            = false
  role_arn               = aws_iam_role.rds_proxy_role.arn
  vpc_security_group_ids = [aws_security_group.rds_proxy_sg.id]
  vpc_subnet_ids         = var.private_sub
  auth {
    auth_scheme = "SECRETS"
    iam_auth    = "DISABLED"
    secret_arn  = aws_secretsmanager_secret.rds_proxy_connection.arn
  }

  depends_on = [aws_secretsmanager_secret_version.rds_proxy_connection]
  tags = {
    Name = "${var.service_name}-rds-proxy"
  }
}

resource "aws_db_proxy_default_target_group" "rds_proxy" {
  db_proxy_name = aws_db_proxy.rds_proxy.name

  connection_pool_config {
    connection_borrow_timeout    = 120
    max_connections_percent      = 70
    max_idle_connections_percent = 50
  }
}

resource "aws_db_proxy_target" "rds_proxy" {
  db_cluster_identifier = var.cluster_id
  db_proxy_name         = aws_db_proxy.rds_proxy.name
  target_group_name     = aws_db_proxy_default_target_group.rds_proxy.name
}

###############################################
# Secret Manager
# RDS Proxyから接続するDB情報
###############################################
resource "aws_secretsmanager_secret" "rds_proxy_connection" {
  name = "${var.service_name}-rds_proxy-sercet"
}

resource "aws_secretsmanager_secret_version" "rds_proxy_connection" {
  secret_id = aws_secretsmanager_secret.rds_proxy_connection.id
  secret_string = jsonencode({
    username : data.aws_ssm_parameter.db_username.value
    password : data.aws_ssm_parameter.db_password.value
    engine : "mysql"
    host : data.aws_ssm_parameter.db_host.value
    port : 3306
    dbClusterIdentifier : var.cluster_id
  })
}

###############################################
# IAM
###############################################
resource "aws_iam_role" "rds_proxy_role" {
  name               = "${var.service_name}-rds-proxy-role"
  assume_role_policy = file("../files/role/rds_proxy_assume_role.json")

  tags = {
    Name = "${var.service_name}-rds-proxy-role"
  }
}

resource "aws_iam_role_policy" "ecs_policy" {
  name = "${var.service_name}-rds-proxy-policy"
  role = aws_iam_role.rds_proxy_role.id

  policy = file("../files/policy/rds-proxy-policy.json")
}

###############################################
# Security Group
###############################################
resource "aws_security_group" "rds_proxy_sg" {
  vpc_id      = var.target_vpc
  name        = "${var.service_name}-rds_proxy_sg"
  description = "${var.service_name}-rds_proxy_sg"

  tags = {
    Name = "${var.service_name}-rds_proxy_sg"
  }
}

resource "aws_security_group_rule" "rds_proxy_sg_ingress" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.rds_proxy_sg.id
}

resource "aws_security_group_rule" "rds_proxy_sg_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.rds_proxy_sg.id
  depends_on        = [aws_security_group.rds_proxy_sg]
}
