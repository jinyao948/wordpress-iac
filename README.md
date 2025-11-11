# wpdemo WordPress Infrastructure as Code

Terraform modules for the wpdemo WordPress deployment on AWS (`ap-southeast-1`). The stack provisions networking, security boundaries, Auto Scaling EC2 instances that run the containerized WordPress build, RDS MySQL, SSM secrets, IAM roles (including GitHub OIDC), and ECR.

## Assignment Mapping
- **Item 2 – Database:** Amazon RDS MySQL 8.x (`db.t4g.micro`, gp3 20 GB) in private subnets, reachable only from the WordPress EC2 security group.
- **Item 4 – Infrastructure as Code:** Every AWS component (VPC, ALB, Auto Scaling Group + launch template, RDS, IAM, SSM, CloudWatch, ECR) is declared via Terraform `~> 1.9`, eliminating manual console drift.
- **Item 6 – Two Repositories:** This repo covers infra; [`wordpress-app`](../wordpress-app) builds the Docker image and CI/CD workflow that GitHub Actions pushes to ECR and rolls out through the ASG.
- **Item 7 – Cost Posture:** Uses public subnets with `assign_public_ip` (no NAT), tiny instance classes, lifecycle-managed ECR, and documents teardown to ensure resources are destroyed immediately after demos.
- **Item 8 – Documentation:** README + `SCALING.md` + `COST_NOTES.md` describe operations, evidence capture, and shutdown steps; inline comments explain the trickier modules.

## Getting Started

```bash
# initialise (runs terraform -chdir=envs/dev init)
make init

# review changes
make plan

# apply / destroy
make apply
make destroy
```

- Terraform state is **not** committed; keep `terraform.tfstate` private (remote backend optional for production).
- If AWS upgrades the default MySQL minor version, set `var.engine_version = null` or bump the default in `modules/rds-mysql`.
- The ASG launch template expects the multi-arch WordPress image published by the CI pipeline; new environments should update `wordpress_image` accordingly.

## Secrets & Bootstrap Flow
- Random DB password and WordPress salts are generated once per environment and stored as SecureStrings in SSM Parameter Store (`/wpdemo/dev/...`).
- User data (`modules/compute/templates/user_data.sh.tmpl`) fetches every required parameter before rendering the systemd service so misconfigurations fail fast.
- Optional bootstrap admin credentials live under `/wpdemo/dev/wp/bootstrap/*`; rotate or delete them after the first WordPress login.
- The future S3 offload bucket placeholder (`/wpdemo/dev/wp/s3/bucket_name`) is seeded here so the WordPress app can read it once the actual bucket is provisioned.

## Scaling & Load Test Evidence
See `SCALING.md` for the exact `hey` command (`hey -z 5m -c 200 -q 20 …`), monitoring views, and screenshots demonstrating the ASG doubling from 1→2 instances when CPU exceeds the 45 % target. The same document outlines how to revert to steady state.

## Teardown & Cost Notes
`COST_NOTES.md` lists every billable component plus the destroy procedure:
1. Empty the ECR repository (or rely on `force_delete = true` if enabled).
2. `make destroy` (Terraform destroys all remaining resources in `envs/dev`).
3. Confirm RDS snapshots/ECR images are gone to avoid residual charges.

## Additional References
- CI/CD (GitHub Actions) runs Trivy, builds a multi-arch image, and refreshes the ASG—details live in the application repo’s README.
- Architecture diagrams, screenshots, and submission notes live in the shared documentation folder referenced in the interview deliverables.
