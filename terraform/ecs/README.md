# ECS Terraform Configuration

Infrastructure as Code để triển khai ECS Fargate với Application Load Balancer.

## Resources được tạo

- **ECS Cluster**: khoi-ecs-cluster
- **ECS Service**: khoi-service (Fargate)
- **Task Definition**: khoi-task
- **Application Load Balancer**: khoi-alb
- **Target Group**: Route traffic đến ECS tasks
- **Security Groups**: ALB SG + ECS Tasks SG
- **IAM Roles**: Task Execution Role + Task Role
- **CloudWatch Log Group**: /ecs/khoi-task
- **Auto Scaling**: CPU và Memory based (1-10 tasks)

## Yêu cầu

- VPC `khoi-vpc` đã được tạo (từ folder `terraform/vpc`)
- Terraform >= 1.0
- AWS CLI configured

## Sử dụng

### 1. Cập nhật terraform.tfvars

```hcl
vpc_name           = "khoi-vpc"  # VPC name đã tạo
ecr_repository_url = "YOUR_ACCOUNT.dkr.ecr.ap-southeast-2.amazonaws.com/samar-repo"
```

### 2. Initialize

```bash
cd terraform/ecs
terraform init
```

### 3. Plan

```bash
terraform plan
```

### 4. Apply

```bash
terraform apply
```

### 5. Get ALB URL

```bash
terraform output alb_dns_name
```

## Cấu hình

### Task size
```hcl
task_cpu    = "512"   # 0.5 vCPU
task_memory = "1024"  # 1GB RAM
```

### Số lượng tasks
```hcl
desired_count = 2
```

## Update Service

Sau khi push image mới:

```bash
aws ecs update-service \
  --cluster khoi-ecs-cluster \
  --service khoi-service \
  --force-new-deployment
```

## Destroy

```bash
terraform destroy
```
