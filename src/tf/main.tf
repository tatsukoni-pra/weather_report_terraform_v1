module "vpc" {
  source       = "../modules/vpc"
  service_name = var.service_name
}

module "vpc_endpoint" {
  source         = "../modules/vpc_endpoint"
  service_name   = var.service_name
  vpc_id         = module.vpc.vpc_id
  private_sub    = [module.vpc.private_subnet_1a_id, module.vpc.private_subnet_1c_id]
  vpc_cidr_block = module.vpc.cidr_block
}

module "rds" {
  source         = "../modules/rds"
  service_name   = var.service_name
  database_name  = "local"
  private_sub    = [module.vpc.private_subnet_1a_id, module.vpc.private_subnet_1c_id]
  target_vpc     = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.cidr_block
}

module "rds_proxy" {
  source         = "../modules/rds_proxy"
  service_name   = var.service_name
  private_sub    = [module.vpc.private_subnet_1a_id, module.vpc.private_subnet_1c_id]
  target_vpc     = module.vpc.vpc_id
  vpc_cidr_block = module.vpc.cidr_block
  cluster_id     = module.rds.cluster_id
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

module "secret_manager" {
  source       = "../modules/secret_manager"
  service_name = var.service_name
  cluster_id   = module.rds.cluster_id
}
