module "ec2" {
    source = "../modules/ec2"
    instance_type = "t2.micro"
    ami_id = "ami-0c07ed1dc0cea3608"
}
