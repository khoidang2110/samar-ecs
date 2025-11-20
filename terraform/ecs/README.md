# ECS Terraform

Tạo AWS ECS Fargate infrastructure.

## Yêu cầu

- VPC `khoi-vpc` đã tạo (chạy `terraform/vpc` trước)
- Terraform >= 1.0
- AWS CLI configured

## Cách dùng

### 1. Sửa ECR URL

File `terraform.tfvars`:
```hcl
ecr_repository_url = "YOUR_ACCOUNT.dkr.ecr.ap-southeast-2.amazonaws.com/YOUR_REPO"
```

### 2. Deploy

```bash
cd terraform/ecs
terraform init
terraform apply
```

### 3. Lấy thông tin

```bash
terraform output alb_dns_name                     # URL web
terraform output github_actions_access_key_id     # AWS Key cho GitHub
terraform output github_actions_secret_access_key # AWS Secret cho GitHub
```

## Resources tạo ra

- ECS Cluster: `khoi-ecs-cluster`
- ECS Service: `khoi-service` (2 tasks, 0.5 vCPU, 1GB RAM)
- ALB: `khoi-alb`
- IAM User: `github-actions-ecs-deployer` (dùng cho CI/CD)
- Auto Scaling: min 1, max 10 tasks
- CloudWatch Logs: `/ecs/khoi-task`

## Update Service

```bash
aws ecs update-service \
  --cluster khoi-ecs-cluster \
  --service khoi-service \
  --force-new-deployment
```

## Xem Logs

```bash
aws logs tail /ecs/khoi-task --follow
```

## Xóa

```bash
terraform destroy
```

## Tùy chỉnh

File `terraform.tfvars`:
```hcl
task_cpu    = "1024"  # 1 vCPU
task_memory = "2048"  # 2GB RAM
desired_count = 3     # 3 tasks
```
