# Scaling Demonstration (wpdemo-dev)

This environment must prove it can move between 1 and 2 EC2 instances on demand. Use the steps below (already exercised during the interview) any time you need to regenerate evidence.

## Preconditions
- Terraform applied and ASG healthy (`desired = 1`, `min = 1`, `max = 2`).
- `hey` CLI installed (`brew install hey` on macOS).
- AWS CLI profile set to `wpdemo-admin`.

## Terminals
Open three terminals before starting the load test:

1. **Load generator**
   ```bash
   hey -z 5m -c 200 -q 20 http://wpdemo-dev-alb-<hash>.ap-southeast-1.elb.amazonaws.com/
   ```
   This drives ~4 k req/s and is enough to exceed the 45 % CPU target.

2. **ASG watcher**
   ```bash
   AWS_PROFILE=wpdemo-admin watch -n 5 \
     'aws autoscaling describe-auto-scaling-groups \
       --auto-scaling-group-name wpdemo-dev-wp-asg \
       --region ap-southeast-1 \
       --query "AutoScalingGroups[0].[DesiredCapacity,MinSize,MaxSize]" \
       --output table'
   ```

3. **Instance watcher**
   ```bash
   AWS_PROFILE=wpdemo-admin watch -n 5 \
     'aws ec2 describe-instances \
       --region ap-southeast-1 \
       --filters Name=tag:aws:autoscaling:groupName,Values=wpdemo-dev-wp-asg \
       --query "Reservations[*].Instances[*].[InstanceId,State.Name,LaunchTime]" \
       --output table'
   ```

## Screenshots to capture
1. Baseline ASG (desired/min/max, TG with 1 healthy target, CloudWatch CPU low).
2. `hey` terminal running.
3. CloudWatch Monitoring tab showing CPU spike > 45 %.
4. ASG Activity showing “Launching new EC2 instance”.
5. Watch output with desired capacity jumping to 2.
6. Target Group with 2 targets (initial → healthy).
7. Optional: CloudWatch CPU after distribution + final `hey` summary.

## After the test
- Stop `hey` (Ctrl+C) once the screenshots are collected.
- Either wait for automatic scale-in or run:
  ```bash
  AWS_PROFILE=wpdemo-admin aws autoscaling set-desired-capacity \
    --auto-scaling-group-name wpdemo-dev-wp-asg \
    --desired-capacity 1 \
    --region ap-southeast-1
  ```
- Note in the submission if the scale-out was triggered manually (should not be necessary once the load test is in place).
