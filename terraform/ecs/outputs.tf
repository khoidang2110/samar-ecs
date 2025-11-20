output "cluster_id" {
  description = "ECS Cluster ID"
  value       = aws_ecs_cluster.main.id
}

output "cluster_name" {
  description = "ECS Cluster name"
  value       = aws_ecs_cluster.main.name
}

output "cluster_arn" {
  description = "ECS Cluster ARN"
  value       = aws_ecs_cluster.main.arn
}

output "service_id" {
  description = "ECS Service ID"
  value       = aws_ecs_service.main.id
}

output "service_name" {
  description = "ECS Service name"
  value       = aws_ecs_service.main.name
}

output "task_definition_arn" {
  description = "ECS Task Definition ARN"
  value       = aws_ecs_task_definition.main.arn
}

output "task_definition_family" {
  description = "ECS Task Definition family"
  value       = aws_ecs_task_definition.main.family
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_arn" {
  description = "Application Load Balancer ARN"
  value       = aws_lb.main.arn
}

output "alb_zone_id" {
  description = "Application Load Balancer Zone ID"
  value       = aws_lb.main.zone_id
}

output "target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.main.arn
}

output "ecs_task_security_group_id" {
  description = "ECS Tasks Security Group ID"
  value       = aws_security_group.ecs_tasks.id
}

output "alb_security_group_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb.id
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch Log Group name"
  value       = aws_cloudwatch_log_group.ecs.name
}

# IAM Outputs
output "github_actions_user_name" {
  description = "GitHub Actions IAM user name"
  value       = aws_iam_user.github_actions.name
}

output "github_actions_access_key_id" {
  description = "GitHub Actions Access Key ID"
  value       = aws_iam_access_key.github_actions.id
  sensitive   = true
}

output "github_actions_secret_access_key" {
  description = "GitHub Actions Secret Access Key"
  value       = aws_iam_access_key.github_actions.secret
  sensitive   = true
}
