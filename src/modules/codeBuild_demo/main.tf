###############################################
# CodeBuild
###############################################
resource "aws_codebuild_project" "codebuild_demo" {
  name         = "${var.service_name}-codeBuild-demo-v1"
  description  = "${var.service_name}-codeBuild-demo-v1"
  service_role = aws_iam_role.codebuild_demo_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  cache {
    type  = "LOCAL"
    modes = ["LOCAL_DOCKER_LAYER_CACHE", "LOCAL_SOURCE_CACHE"]
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "/aws/codeBuild/${var.service_name}-codeBuild-demo-v1"
      stream_name = "${var.service_name}-codeBuild-demo-v1"
    }
  }

  source {
    type      = "GITHUB"
    location  = local.github_values.target_location
    buildspec = local.github_values.target_buildspec
    git_clone_depth = 1
  }
  source_version = local.github_values.target_branch

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "DUMMY_ENV"
      value = "default-value"
      type  = "PLAINTEXT"
    }
  }

  lifecycle {
    ignore_changes = [
      environment["environment_variable"]
    ]
  }

  tags = {
    Name = "${var.service_name}-codeBuild-demo-v1"
  }
}

###############################################
# IAM
###############################################
resource "aws_iam_role" "codebuild_demo_role" {
  name               = "${var.service_name}-codebuild_demo_role"
  assume_role_policy = file("../files/role/codebuild_demo_role.json")

  tags = {
    Name = "${var.service_name}-codebuild_demo_role"
  }
}

resource "aws_iam_role_policy" "codebuild_demo_policy" {
  name   = "${var.service_name}-codebuild_demo_policy"
  role   = aws_iam_role.codebuild_demo_role.id
  policy = file("../files/policy/codebuild_demo_policy.json")
}
