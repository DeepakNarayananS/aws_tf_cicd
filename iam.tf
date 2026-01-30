# IAM User: dnsec
resource "aws_iam_user" "dnsec" {
  name = "dnsec"

  tags = {
    Description = "DNS and Security operations user"
  }
}

# Access Key for dnsec user (reference existing keys via variables)
resource "aws_iam_access_key" "dnsec" {
  user = aws_iam_user.dnsec.name
}

# EC2 Full Management Policy
resource "aws_iam_user_policy" "dnsec_ec2_policy" {
  name   = "dnsec-ec2-full-access"
  user   = aws_iam_user.dnsec.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# S3 Full Management Policy
resource "aws_iam_user_policy" "dnsec_s3_policy" {
  name   = "dnsec-s3-full-access"
  user   = aws_iam_user.dnsec.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:*"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Read-Only Policy for dnsec user
resource "aws_iam_user_policy" "dnsec_iam_policy" {
  name   = "dnsec-iam-read-access"
  user   = aws_iam_user.dnsec.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:GetUser",
          "iam:ListAccessKeys",
          "iam:GetAccessKeyLastUsed"
        ]
        Resource = "arn:aws:iam::*:user/dnsec"
      }
    ]
  })
}
