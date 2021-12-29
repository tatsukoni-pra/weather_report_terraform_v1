variable "service_name" {
  description = "VPC Service Name"
}

locals {
  vpc = {
    cidr_block = "10.0.0.0/16"
  }

  public_subnet_1a = {
    cidr_block = "10.0.0.0/24"
    az         = "ap-northeast-1a"
  }
  public_subnet_1c = {
    cidr_block = "10.0.2.0/24"
    az         = "ap-northeast-1c"
  }
  private_subnet_1a = {
    cidr_block = "10.0.1.0/24"
    az         = "ap-northeast-1a"
  }
  private_subnet_1c = {
    cidr_block = "10.0.3.0/24"
    az         = "ap-northeast-1c"
  }
}
