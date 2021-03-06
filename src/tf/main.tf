###############################################
# For Common Resource
###############################################
module "vpc" {
  source       = "../modules/vpc"
  service_name = var.service_name
}

module "route53" {
  source       = "../modules/route53"
  service_name = var.service_name
  vpc_id       = module.vpc.vpc_id
}

# module "vpc_endpoint" {
#   source         = "../modules/vpc_endpoint"
#   service_name   = var.service_name
#   vpc_id         = module.vpc.vpc_id
#   private_sub    = [module.vpc.private_subnet_1a_id, module.vpc.private_subnet_1c_id]
#   vpc_cidr_block = module.vpc.cidr_block
#   private_route_table_id = module.vpc.private_route_table_id
# }

###############################################
# For Bitcoin Resource
###############################################
# module "ecr_bitcoin" {
#   source       = "../modules/ecr"
#   service_name = var.service_name
#   rep_name     = "bitcoin-v1"
# }

# module "ecs_bitcoin" {
#   source       = "../modules/ecs_bitcoin"
#   service_name = var.service_name
#   vpc_id       = module.vpc.vpc_id
#   public_sub   = [module.vpc.public_subnet_1a_id, module.vpc.public_subnet_1c_id]
#   account_id   = var.account_id
# }

###############################################
# For Inspection Resource
###############################################
# module "rds" {
#   source         = "../modules/rds"
#   service_name   = var.service_name
#   database_name  = "local"
#   private_sub    = [module.vpc.private_subnet_1a_id, module.vpc.private_subnet_1c_id]
#   target_vpc     = module.vpc.vpc_id
#   vpc_cidr_block = module.vpc.cidr_block
# }

# module "rds_proxy" {
#   source          = "../modules/rds_proxy"
#   service_name    = var.service_name
#   private_sub     = [module.vpc.private_subnet_1a_id, module.vpc.private_subnet_1c_id]
#   target_vpc      = module.vpc.vpc_id
#   vpc_cidr_block  = module.vpc.cidr_block
#   cluster_id      = module.rds.cluster_id
#   private_zone_id = module.route53.private_zone_id
# }

###############################################
# For EC2 Line Notify Resource
###############################################
module "ec2_line_notify" {
  source           = "../modules/ec2_line_notify"
  vpc_id           = module.vpc.vpc_id
  vpc_cidr_block   = module.vpc.cidr_block
  public_sub_id    = module.vpc.public_subnet_1a_id
  public_sub_1c_id = module.vpc.public_subnet_1c_id
  certificate_arn  = data.aws_ssm_parameter.awesome_certificate_arn.value
  zone_id          = data.aws_ssm_parameter.awesome_route53_zone_id.value
  domain           = var.awesome_domain
}

module "ecr" {
  source       = "../modules/ecr"
  service_name = var.service_name
  rep_name     = "lambda-rds-demo"
}

module "lambda" {
  source         = "../modules/lambda"
  service_name   = var.service_name
  vpc_id         = module.vpc.vpc_id
  private_sub    = [module.vpc.private_subnet_1a_id, module.vpc.private_subnet_1c_id]
  vpc_cidr_block = module.vpc.cidr_block
}

module "codeBuild_demo" {
  source       = "../modules/codeBuild_demo"
  service_name = var.service_name
}
