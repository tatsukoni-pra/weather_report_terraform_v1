resource "aws_rds_cluster" "service_cluster" {
  cluster_identifier              = "${var.service_name}-aurora"
  engine                          = local.engine
  engine_version                  = local.engine_version
  availability_zones              = local.availability_zones
  db_subnet_group_name            = aws_db_subnet_group.service_cluster.name
  db_cluster_parameter_group_name = "${var.service_name}-dbcluster-parameter"
  database_name                   = var.database_name
  master_username                 = data.aws_ssm_parameter.db_master_username.value
  master_password                 = data.aws_ssm_parameter.db_master_password.value
  backup_retention_period         = local.backup_retention_period
  port                            = local.port
  preferred_maintenance_window    = local.preferred_maintenance_window
  skip_final_snapshot             = false
  storage_encrypted               = true
  kms_key_id                      = aws_kms_key.rds_storage.arn
  deletion_protection             = false
  vpc_security_group_ids = [
    aws_security_group.service_db_security_group.id
  ]

  depends_on = [aws_db_subnet_group.service_cluster]
  lifecycle {
    ignore_changes = [master_password, availability_zones, tags["Schedule"]]
  }
  tags = {
    Name        = "${var.service_name}-rds"
  }
}

resource "aws_rds_cluster_instance" "service_db" {
  count                        = local.cluster_instance_count
  identifier                   = "${var.service_name}-rds-${count.index}"
  cluster_identifier           = aws_rds_cluster.service_cluster.id
  instance_class               = local.instance_class
  db_subnet_group_name         = aws_db_subnet_group.service_cluster.name
  publicly_accessible          = false
  performance_insights_enabled = false
  engine                       = local.engine
  engine_version               = local.engine_version
  db_parameter_group_name      = "${var.service_name}-db-parameter"
  auto_minor_version_upgrade   = true
  apply_immediately            = true

  tags = {
    Name        = "${var.service_name}-rds"
  }
}

resource "aws_kms_key" "rds_storage" {
  description             = "key to encrypt rds storage."
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "${var.service_name}-rds-kms"
  }
}

resource "aws_db_subnet_group" "service_cluster" {
  name        = "${var.service_name}-db-subnet-group"
  description = "${var.service_name} db subnet group"
  subnet_ids  = var.private_sub

  tags = {
    Name        = var.service_name
  }
}

resource "aws_security_group" "service_db_security_group" {
  vpc_id      = var.target_vpc
  name        = "${var.service_name}-rds-sg"
  description = "${var.service_name} rds sg"

  tags = {
    Name        = "${var.service_name}-rds"
  }
}

resource "aws_security_group_rule" "vpc_cidr_ingress" {
  description       = "VPC"
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr_block]
  security_group_id = aws_security_group.service_db_security_group.id
}

resource "aws_security_group_rule" "service_db_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.service_db_security_group.id
}

resource "aws_rds_cluster_parameter_group" "default" {
  name   = var.cluster_parameter_group
  family = var.cluster_parameter_family
  tags = {
    service     = var.service_name
    environment = var.env
  }
  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_filesystem"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
  }
  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }
  parameter {
    name  = "collation_connection"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "collation_server"
    value = "utf8mb4_general_ci"
  }
  parameter {
    name  = "time_zone"
    value = "Asia/Tokyo"
  }
}

resource "aws_db_parameter_group" "db_parameter_group" {
  name   = var.parameter_group
  family = var.parameter_family
  tags = {
    Name        = "${var.service_name}-db_paramter_group"
    Environment = var.env
    Service     = var.service_name
  }
}
