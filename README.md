# wpdemo WordPress Infrastructure as Code

This repository hosts the Terraform infrastructure that provisions the AWS foundation for the wpdemo WordPress deployment. The stack will cover networking, compute, database, storage, observability, and deployment identity in the `ap-southeast-1` region.

## Assignment Mapping
- **Item 2 – Database:** Terraform creates an Amazon RDS MySQL 8.x cluster, with connectivity restricted to the ECS service security group.
- **Item 4 – Infrastructure as Code:** Every AWS resource (VPC, ALB, ECS/Fargate, RDS, S3, IAM, SSM, CloudWatch, ECR) is defined here using Terraform `~> 1.9`, keeping the environment reproducible and drift-free.
- **Item 6 – Two Repositories:** This repo delivers the infrastructure layer; a separate `wordpress-app` repository will contain the WordPress image, configuration, and CI/CD workflows.
- **Item 7 – Cost Posture:** Designs target free-tier-friendly components (public subnets with `assign_public_ip`, no NAT, `db.t4g.micro`, minimal gp3 storage, lifecycle-managed ECR) and will document teardown instructions to avoid lingering charges.
- **Item 8 – Documentation:** README, scaling notes, and cost notes originate here, ensuring clear operator guidance and traceability.

## Usage
- Manage state with Terraform `~> 1.9` against AWS provider `~> 5.60`.
- Use the included `Makefile` targets (`make init|plan|apply|destroy`) for consistent workflows.
- Additional modules, environment compositions, and documentation will expand on this scaffold as the implementation progresses.
