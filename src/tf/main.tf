module "vpc" {
  source       = "../modules/vpc"
  service_name = var.service_name
}


# module "rds" {
#   source                       = "../modules/rds"
#   service_name                 = var.service_name
#   database_name                = var.service_name
#   db_option_group              = "default:aurora-mysql-5-7"
#   private_sub                  = [module.vpc.private_subnet_1a_id, module.vpc.private_subnet_1c_id]
#   target_vpc                   = module.vpc.vpc_id
#   vpc_cidr_block               = module.vpc.cidr_block
#   schedule                     = "start0900-stop2200-weekdays"
#   parameter_family             = "aurora-mysql5.7"
#   cluster_parameter_family     = "aurora-mysql5.7"
#   internal_domain              = module.vpc.internal_zoneid
# }
