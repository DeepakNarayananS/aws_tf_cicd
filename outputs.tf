output "iam_user_name" {
  value       = aws_iam_user.dnsec.name
  description = "IAM user name"
}

output "iam_user_arn" {
  value       = aws_iam_user.dnsec.arn
  description = "IAM user ARN"
}

output "ec2_instance_id" {
  value       = aws_instance.app_server.id
  description = "EC2 instance ID"
}

output "ec2_instance_public_ip" {
  value       = aws_instance.app_server.public_ip
  description = "EC2 instance public IP address"
}

output "s3_bucket_name" {
  value       = aws_s3_bucket.app_bucket.id
  description = "S3 bucket name"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.app_bucket.arn
  description = "S3 bucket ARN"
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "VPC ID"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "Public subnet ID"
}

output "terraform_state_bucket" {
  value       = aws_s3_bucket.terraform_state.id
  description = "Terraform state backend S3 bucket"
}

output "dynamodb_lock_table" {
  value       = aws_dynamodb_table.terraform_locks.name
  description = "DynamoDB table for Terraform state locking"
}
