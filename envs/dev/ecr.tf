module "ecr" {
  source = "../../modules/ecr"

  project = local.project
  env     = local.env
  tags    = local.tags
}

output "ecr_summary" {
  value = {
    repository_name = module.ecr.repository_name
    repository_url  = module.ecr.repository_url
  }
}
