resource "aws_ecr_repository" "ecr" {
  name                 = "${var.service_name}-${var.rep_name}"
  image_tag_mutability = "MUTABLE"
}
