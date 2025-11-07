module "alb" {
  source = "../../modules/alb"

  project               = local.project
  env                   = local.env
  tags                  = local.tags
  vpc_id                = module.vpc.vpc_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  alb_security_group_id = module.vpc.alb_sg_id
}

output "alb_summary" {
  value = {
    dns_name          = module.alb.alb_dns_name
    alb_arn           = module.alb.alb_arn
    target_group_arn  = module.alb.target_group_arn
    listener_http_arn = module.alb.listener_arn
  }
}
