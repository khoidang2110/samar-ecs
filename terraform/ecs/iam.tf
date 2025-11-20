# IAM User for GitHub Actions deployment
resource "aws_iam_user" "github_actions" {
  name = "github-actions-ecs-deployer"
  path = "/service-accounts/"

  tags = {
    Name        = "github-actions-ecs-deployer"
    Purpose     = "GitHub Actions ECS Deployment"
    ManagedBy   = "Terraform"
  }
}

# Access Key for GitHub Actions
resource "aws_iam_access_key" "github_actions" {
  user = aws_iam_user.github_actions.name
}

# IAM Policy for ECS Deployment
resource "aws_iam_policy" "ecs_deploy" {
  name        = "ECS-Deployment-Policy"
  description = "Policy for GitHub Actions to deploy to ECS"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ECRAccess"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECSAccess"
        Effect = "Allow"
        Action = [
          "ecs:UpdateService",
          "ecs:DescribeServices",
          "ecs:DescribeTasks",
          "ecs:DescribeTaskDefinition",
          "ecs:RegisterTaskDefinition",
          "ecs:ListTasks",
          "ecs:DescribeClusters"
        ]
        Resource = "*"
      },
      {
        Sid    = "IAMPassRole"
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = [
          aws_iam_role.ecs_task_execution_role.arn,
          aws_iam_role.ecs_task_role.arn
        ]
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "ECS-Deployment-Policy"
  }
}

# Attach policy to user
resource "aws_iam_user_policy_attachment" "github_actions_deploy" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.ecs_deploy.arn
}

# Optional: Additional ECR permissions for specific repository
resource "aws_iam_policy" "ecr_full_access" {
  name        = "ECR-Repository-Access"
  description = "Full access to specific ECR repository"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "ECR-Repository-Access"
  }
}

resource "aws_iam_user_policy_attachment" "github_actions_ecr" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.ecr_full_access.arn
}
