variable "service_name" {
  description = "Service Name"
}

locals {
  github_values = {
    target_branch    = "main"
    target_location  = "https://github.com/tatsukoni-pra/codebuild-demo-v1"
    target_buildspec = "buildspec/buildspec.yml"
  }
}
