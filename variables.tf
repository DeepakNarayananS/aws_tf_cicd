variable "region" {
  type        = string
  description = "AWS region for resource deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Environment name (dev, staging, prod)"
  default     = "dev"
}

variable "aws_access_key_id" {
  type        = string
  description = "AWS Access Key ID for IAM user"
  sensitive   = true
}

variable "aws_secret_access_key" {
  type        = string
  description = "AWS Secret Access Key for IAM user"
  sensitive   = true
}

variable "ec2_ami_id" {
  type        = string
  description = "AMI ID for EC2 instance"
  default     = "ami-0440d3b780d96b29d"
}

variable "ec2_instance_type" {
  type        = string
  description = "EC2 instance type (free-tier eligible)"
  default     = "t2.micro"
}

variable "s3_bucket_name" {
  type        = string
  description = "S3 bucket name for application data"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for public subnet"
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_cidr" {
  type        = string
  description = "CIDR block allowed for SSH access"
  default     = "0.0.0.0/0"
}
