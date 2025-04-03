module "ecr" {
  source = "./modules/ecr"

  name                 = "the-plug-backend-repository"
  scan_on_push         = false
  image_tag_mutability = "MUTABLE"
  encryption_type      = "KMS"
  kms_key              = module.kms_ecr.key_arn

  lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Remove untagged images older than 7 days"
      selection = {
        tagStatus   = "untagged"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 7
      }
      action = {
        type = "expire"
      }
    }]
  })

  repository_policy = jsonencode({
    Version = "2008-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        AWS = "arn:aws:iam::123456789012:role/ecr-ec2-task-role"
      },
      Action = [
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "ecr:BatchCheckLayerAvailability"
      ]
    }]
  })
}

module "kms_ecr" {
  source = "./modules/kms"

  description         = "Key for ECR encryption"
  alias_name          = "ecr"
  enable_key_rotation = false

  additional_policies = data.aws_iam_policy_document.ecr_kms_policy.json
}

data "aws_iam_policy_document" "ecr_kms_policy" {
  statement {
    sid    = "AllowECRService"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ecr.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowEC2TaskRole"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::123456789012:role/ecr-ec2-task-role"]
    }
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}