variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}

variable "cluster_name" {
  description = "ECS Cluster name"
  type        = string
  default     = "khoi-ecs-cluster"
}

variable "service_name" {
  description = "ECS Service name"
  type        = string
  default     = "khoi-service"
}

variable "task_family" {
  description = "ECS Task Definition family"
  type        = string
  default     = "khoi-task"
}

variable "container_name" {
  description = "Container name"
  type        = string
  default     = "samar-container"
}

variable "ecr_repository_url" {
  description = "ECR repository URL"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
  default     = 80
}

variable "task_cpu" {
  description = "Task CPU units"
  type        = string
  default     = "512"
}

variable "task_memory" {
  description = "Task memory in MB"
  type        = string
  default     = "1024"
}

variable "desired_count" {
  description = "Desired number of tasks"
  type        = number
  default     = 2
}

variable "vpc_name" {
  description = "VPC name tag to lookup"
  type        = string
  default     = "khoi-vpc"
}
