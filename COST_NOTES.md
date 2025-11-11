# Cost Notes & Teardown Checklist

The wpdemo-dev environment stays within the AWS free-tier footprint as long as it is only powered on for short demo windows.

## Billable components
- **ALB (Application Load Balancer)** – hourly + LCU charges while running.
- **EC2 Auto Scaling instances** – `t4g.small` (or `t4g.micro` during tests) with public IPs. Charges stop when the ASG desired capacity is set to zero or the stack is destroyed.
- **RDS MySQL** – `db.t4g.micro`, gp3 20 GB, single-AZ, 7-day backups.
- **ECR storage** – each pushed image layer incurs S3-like storage costs.
- **CloudWatch logs/metrics** – minimal, but drop log groups if exporting elsewhere.

## Teardown steps (post-screenshots/demo)
1. **Stop load tests** and ensure the ASG is back to `desired = 1`.
2. **Empty ECR** (required unless `force_delete = true` is set):
   ```bash
   AWS_PROFILE=wpdemo-admin aws ecr list-images \
     --repository-name wpdemo-dev-wordpress \
     --region ap-southeast-1

   AWS_PROFILE=wpdemo-admin aws ecr batch-delete-image \
     --repository-name wpdemo-dev-wordpress \
     --region ap-southeast-1 \
     --image-ids imageDigest=<digest1> imageDigest=<digest2> ...
   ```
3. **Destroy with Terraform** (Makefile already scopes to `envs/dev`):
   ```bash
   make destroy  # runs terraform -chdir=envs/dev destroy
   ```
4. **Verify cleanup** in the AWS console (VPC list, RDS snapshots, ECR).
5. **Remove documentation artifacts** from S3/CloudWatch if uploaded manually.

Document the teardown timestamp in the submission so reviewers know the account is clean and charges stopped.
