# Terraform Infrastructure - AWS ECS Deployment

Hướng dẫn triển khai infrastructure AWS ECS Fargate với Application Load Balancer sử dụng Terraform.

## 📋 Tổng quan

Infrastructure bao gồm:
- **VPC**: Virtual Private Cloud với public/private subnets, NAT Gateway
- **ECS**: Elastic Container Service với Fargate, Auto Scaling
- **ALB**: Application Load Balancer
- **IAM**: Roles và Users cho ECS tasks và CI/CD
- **CloudWatch**: Logs và monitoring

## 🏗️ Cấu trúc thư mục

```
terraform/
├── vpc/              # VPC Module (độc lập)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── versions.tf
│
└── ecs/              # ECS Module (độc lập)
    ├── main.tf       # ECS resources chính
    ├── iam.tf        # IAM roles và users
    ├── variables.tf
    ├── outputs.tf
    ├── versions.tf
    ├── terraform.tfvars
    └── README.md
```

## 🚀 Triển khai từng bước

### Bước 1: Chuẩn bị

**Yêu cầu:**
- Terraform >= 1.0
- AWS CLI configured
- AWS credentials với quyền Administrator hoặc các quyền sau:
  - VPC, EC2
  - ECS, ECR
  - IAM
  - ElasticLoadBalancing
  - CloudWatch

**Kiểm tra AWS CLI:**
```bash
aws sts get-caller-identity
```

### Bước 2: Triển khai VPC

VPC phải được tạo trước vì ECS cần subnet IDs.

```bash
# Di chuyển vào folder VPC
cd terraform/vpc

# Initialize Terraform
terraform init

# Review plan
terraform plan

# Apply (tạo VPC infrastructure)
terraform apply
```

**Resources được tạo:**
- ✅ VPC với CIDR `10.0.0.0/16`
- ✅ 2 Public Subnets (cho ALB)
- ✅ 2 Private Subnets (cho ECS tasks - không dùng do lỗi ECR)
- ✅ Internet Gateway
- ✅ NAT Gateway (cho private subnet internet access)
- ✅ Route Tables
- ✅ Security Group cơ bản

**Outputs quan trọng:**
```bash
terraform output vpc_id
terraform output public_subnets
terraform output private_subnets
```

### Bước 3: Cấu hình ECS

Trước khi triển khai ECS, cần cập nhật ECR repository URL.

```bash
cd ../ecs

# Mở file terraform.tfvars và cập nhật
vim terraform.tfvars
```

**Cập nhật các giá trị:**
```hcl
# ECR Repository URL (bắt buộc)
ecr_repository_url = "YOUR_ACCOUNT_ID.dkr.ecr.REGION.amazonaws.com/YOUR_REPO_NAME"

# VPC name (phải khớp với VPC đã tạo)
vpc_name = "khoi-vpc"

# ECS Configuration (tùy chọn)
cluster_name = "khoi-ecs-cluster"
service_name = "khoi-service"
task_family  = "khoi-task"

# Task size (tùy chọn)
task_cpu    = "512"   # 0.5 vCPU
task_memory = "1024"  # 1GB RAM

# Số lượng tasks (tùy chọn)
desired_count = 2
```

### Bước 4: Triển khai ECS

```bash
# Initialize Terraform
terraform init

# Review plan (kiểm tra 21 resources sẽ được tạo)
terraform plan

# Apply (tạo ECS infrastructure)
terraform apply

# Xác nhận bằng cách gõ: yes
```

**Resources được tạo:**

**ECS Resources:**
- ✅ ECS Cluster: `khoi-ecs-cluster`
- ✅ ECS Service: `khoi-service` (Fargate)
- ✅ Task Definition: `khoi-task`
- ✅ CloudWatch Log Group: `/ecs/khoi-task`

**Load Balancer:**
- ✅ Application Load Balancer: `khoi-alb`
- ✅ Target Group
- ✅ HTTP Listener (port 80)

**Security Groups:**
- ✅ ALB Security Group (allow 80, 443 from internet)
- ✅ ECS Tasks Security Group (allow 80 from ALB only)

**IAM Resources:**
- ✅ ECS Task Execution Role (pull images, write logs)
- ✅ ECS Task Role (cho application)
- ✅ IAM User: `github-actions-ecs-deployer`
- ✅ IAM Policies:
  - `ECS-Deployment-Policy` (ECS + ECR + CloudWatch)
  - `ECR-Repository-Access` (ECR full access)

**Auto Scaling:**
- ✅ Auto Scaling Target (min: 1, max: 10)
- ✅ CPU-based scaling (target: 70%)
- ✅ Memory-based scaling (target: 80%)

### Bước 5: Lấy thông tin quan trọng

```bash
# Lấy ALB URL
terraform output alb_dns_name
# Output: khoi-alb-XXXXXXXXXX.ap-southeast-2.elb.amazonaws.com

# Lấy GitHub Actions credentials
terraform output github_actions_access_key_id
terraform output github_actions_secret_access_key

# Lấy tất cả outputs
terraform output
```

### Bước 6: Cấu hình GitHub Secrets

Vào GitHub repository → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

Thêm các secrets sau:

```
AWS_ACCESS_KEY_ID = <giá trị từ terraform output>
AWS_SECRET_ACCESS_KEY = <giá trị từ terraform output>
AWS_REGION = ap-southeast-2
```

### Bước 7: Kiểm tra deployment

```bash
# Kiểm tra ECS service
aws ecs describe-services \
  --cluster khoi-ecs-cluster \
  --services khoi-service

# Kiểm tra tasks đang chạy
aws ecs list-tasks \
  --cluster khoi-ecs-cluster \
  --service-name khoi-service

# Xem logs
aws logs tail /ecs/khoi-task --follow

# Kiểm tra ALB target health
aws elbv2 describe-target-health \
  --target-group-arn <TARGET_GROUP_ARN>
```

**Truy cập ứng dụng:**
```
http://khoi-alb-XXXXXXXXXX.ap-southeast-2.elb.amazonaws.com
```

## 🔧 Quản lý và Cập nhật

### Update task size

Sửa file `terraform.tfvars`:
```hcl
task_cpu    = "1024"  # 1 vCPU
task_memory = "2048"  # 2GB RAM
```

Sau đó apply:
```bash
terraform apply
```

### Scale service

```bash
# Manual scaling
aws ecs update-service \
  --cluster khoi-ecs-cluster \
  --service khoi-service \
  --desired-count 5

# Hoặc update terraform.tfvars
desired_count = 5
terraform apply
```

### Deploy image mới

**Cách 1: Qua GitHub Actions (Recommended)**
```bash
git add .
git commit -m "update: new feature"
git push
```

**Cách 2: Manual force deployment**
```bash
aws ecs update-service \
  --cluster khoi-ecs-cluster \
  --service khoi-service \
  --force-new-deployment
```

### Update task definition

```bash
cd terraform/ecs
terraform apply
```

ECS sẽ tự động rolling update với blue/green deployment.

## 📊 Monitoring và Troubleshooting

### Xem logs real-time

```bash
# CloudWatch Logs
aws logs tail /ecs/khoi-task --follow

# Hoặc vào AWS Console
# CloudWatch → Log groups → /ecs/khoi-task
```

### Kiểm tra service events

```bash
aws ecs describe-services \
  --cluster khoi-ecs-cluster \
  --services khoi-service \
  --query 'services[0].events[0:5]'
```

### Common issues

**1. Tasks không start được (503 Error)**
- Kiểm tra security groups
- Kiểm tra ECR image tồn tại
- Xem logs: `aws logs tail /ecs/khoi-task`

**2. Health check fail**
- Task definition có health check: `curl -f http://localhost:80/`
- Đảm bảo container expose port 80
- Dockerfile phải chạy web server

**3. Tasks không pull được image từ ECR**
- Tasks phải có internet access
- Solution: Chạy trong public subnet với `assign_public_ip = true` (đã config)
- Hoặc: Tạo VPC Endpoints cho ECR

**4. Auto scaling không hoạt động**
- Đợi ít nhất 5-10 phút để metrics thu thập
- Kiểm tra CloudWatch metrics

## 🗑️ Xóa Infrastructure

**Cảnh báo:** Lệnh này sẽ xóa toàn bộ infrastructure!

```bash
# Xóa ECS trước
cd terraform/ecs
terraform destroy

# Sau đó xóa VPC
cd ../vpc
terraform destroy
```

**Manual cleanup nếu cần:**
```bash
# Xóa stopped tasks
aws ecs list-tasks --cluster khoi-ecs-cluster --desired-status STOPPED

# Xóa log streams cũ
aws logs describe-log-streams --log-group-name /ecs/khoi-task
```

## 🔐 Security Best Practices

✅ **Đã implement:**
- ECS tasks trong public subnet (để access ECR)
- Security groups theo principle of least privilege
- IAM roles với minimum required permissions
- CloudWatch logs enabled
- Auto scaling enabled
