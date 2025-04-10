module "ecr" {
  source = "./modules/ecr"

  name                 = "the-plug-backend-repository"
  scan_on_push         = false
  image_tag_mutability = "MUTABLE"

  lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Remove untagged images older than 3 days"
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 3 versions of images"
        selection = {
          tagStatus  = "tagged"
          countType  = "imageCountMoreThan"
          countValue = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })

  repository_policy = jsonencode({
    Version = "2008-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = module.asg.ec2_role_arn
      },
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }]
  })

  tags = {
    Environment = "dev"
  }
}