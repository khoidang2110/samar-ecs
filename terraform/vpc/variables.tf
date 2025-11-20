variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_name" {
  description = "Name for VPC"
  type        = string
  default     = "khoi-vpc"
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-southeast-2"
}
