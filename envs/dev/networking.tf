output "security_groups" {
  value = {
    alb = module.vpc.alb_sg_id
    ec2 = module.vpc.ec2_sg_id
    rds = module.vpc.rds_sg_id
  }
}
