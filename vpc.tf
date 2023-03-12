module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"

  version = "~> 3.0"

  name = "cyber_vpc"
  cidr = "10.0.0.0/21"

  azs                 = ["${local.region}a", "${local.region}b", "${local.region}c"]
  database_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets      = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  create_database_subnet_group = true

  tags = {
    Name       = "cyber-vpc"
  }
}