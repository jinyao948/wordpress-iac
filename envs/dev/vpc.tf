module "vpc" {
  source = "../../modules/vpc"

  project = "wpdemo"
  env     = "dev"
}

output "vpc_summary" {
  value = {
    vpc_id              = module.vpc.vpc_id
    public_subnet_ids   = module.vpc.public_subnet_ids
    private_subnet_ids  = module.vpc.private_subnet_ids
    public_route_table  = module.vpc.public_route_table_id
    private_route_table = module.vpc.private_route_table_id
  }
}
