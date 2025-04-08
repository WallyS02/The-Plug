# IAM Role for CloudWatch Agent
resource "aws_iam_role" "cw_agent" {
  count = var.create_iam_role ? 1 : 0
  name  = "CloudWatchAgentRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cw_agent" {
  count      = var.create_iam_role ? 1 : 0
  role       = aws_iam_role.cw_agent[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}