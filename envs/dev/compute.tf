module "iam_compute" {
  source = "../../modules/iam-compute"

  project          = local.project
  env              = local.env
  tags             = local.tags
  ssm_param_prefix = "/${local.project}/${local.env}"
}

module "compute" {
  source = "../../modules/compute"

  project                   = local.project
  env                       = local.env
  tags                      = local.tags
  public_subnet_ids         = module.vpc.public_subnet_ids
  ec2_security_group_id     = module.vpc.ec2_sg_id
  target_group_arn          = module.alb.target_group_arn
  iam_instance_profile_name = module.iam_compute.instance_profile_name
  ssm_param_prefix          = "/${local.project}/${local.env}"
  region                    = local.region
  instance_type             = "t2.micro"
  db_endpoint               = module.rds_mysql.db_endpoint
}

output "compute_summary" {
  value = {
    asg_name              = module.compute.asg_name
    launch_template_id    = module.compute.launch_template_id
    launch_template_label = module.compute.launch_template_version
  }
}
