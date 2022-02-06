####################################################################
# Secret Manager
# シークレットのタイプは、secret_stringで指定されるkey種類により自動的に変わる
####################################################################
// Amazon RDS データベースの認証情報
resource "aws_secretsmanager_secret" "rds_connection" {
  name = "${var.service_name}-rds-secret-v1"

  tags = {
    Name = "${var.service_name}-rds-secret-v1"
  }
}

resource "aws_secretsmanager_secret_version" "rds_connection" {
  secret_id = aws_secretsmanager_secret.rds_connection.id
  secret_string = jsonencode({
    username : "dummyUserName"
    password : "dummyString"
    engine : "mysql"
    host : "dummyString"
    port : 3306
    dbClusterIdentifier : var.cluster_id # これがあると、type:データベースの認証情報 になるみたい
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

// その他のデータベースの認証情報
resource "aws_secretsmanager_secret" "other_db_connection" {
  name = "${var.service_name}-other-db-secret-v1"

  tags = {
    Name = "${var.service_name}-other-db-secret-v1"
  }
}

resource "aws_secretsmanager_secret_version" "other_db_connection" {
  secret_id = aws_secretsmanager_secret.other_db_connection.id
  secret_string = jsonencode({
    username : "dummyUserName"
    password : "dummyString"
    engine : "mysql"
    host : "dummyString"
    port : 3306
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}

// その他のシークレットのタイプ
resource "aws_secretsmanager_secret" "other_connection" {
  name = "${var.service_name}-other-secret-v1"

  tags = {
    Name = "${var.service_name}-other-secret-v1"
  }
}

resource "aws_secretsmanager_secret_version" "other_connection" {
  secret_id = aws_secretsmanager_secret.other_connection.id
  secret_string = jsonencode({
    key1 : "dummyUserName"
    key2 : "dummyString"
  })

  lifecycle {
    ignore_changes = [secret_string]
  }
}
