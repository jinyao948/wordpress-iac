module "github_oidc" {
  source = "../../modules/iam-github-oidc"

  project                = local.project
  env                    = local.env
  tags                   = local.tags
  github_repository      = "jinyao948/wordpress-app"
  ecr_repository_arn     = module.ecr.repository_arn
  autoscaling_group_name = module.compute.asg_name
  region                 = local.region
}

output "ci_cd_role_arn" {
  value       = module.github_oidc.role_arn
  description = "IAM role that GitHub Actions assumes for ECR pushes and ASG refreshes"
}
