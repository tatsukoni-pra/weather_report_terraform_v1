terraform {
  required_version = "0.14.10"
}

provider "aws" {
  region  = "ap-northeast-1"
  profile = "my-profile"
}
