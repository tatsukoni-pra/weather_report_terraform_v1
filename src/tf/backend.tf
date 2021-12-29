terraform {
  backend "s3" {
    bucket  = "weather-report-tfstates"
    key     = "terraform.tfstate"
    region  = "ap-northeast-1"
    profile = "my-profile"
  }
}
