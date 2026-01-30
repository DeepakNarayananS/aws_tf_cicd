# AWS Terraform Infrastructure & CI/CD Pipeline

Complete Terraform-based AWS infrastructure with GitLab CI/CD automation. This project provisions a free-tier eligible AWS environment with IAM, EC2, S3, VPC, and remote state management.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│                    AWS Account                          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │              VPC (10.0.0.0/16)                   │  │
│  │  ┌────────────────────────────────────────────┐  │  │
│  │  │  Public Subnet (10.0.1.0/24)               │  │  │
│  │  │  ┌──────────────────────────────────────┐  │  │  │
│  │  │  │  EC2 Instance (t2.micro)             │  │  │  │
│  │  │  │  - Free-tier eligible                │  │  │  │
│  │  │  │  - Public IP assigned                │  │  │  │
│  │  │  └──────────────────────────────────────┘  │  │  │
│  │  └────────────────────────────────────────────┘  │  │
│  │                                                  │  │
│  │  Internet Gateway                               │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  IAM User: dnsec                                │  │
│  │  - EC2 Full Access                              │  │
│  │  - S3 Full Access                               │  │
│  │  - IAM Read Access                              │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  S3 Buckets                                      │  │
│  │  - App Data Bucket (AES256 encrypted)           │  │
│  │  - Terraform State Bucket (versioned, locked)   │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
│  ┌──────────────────────────────────────────────────┐  │
│  │  DynamoDB Table: terraform-locks                │  │
│  │  - PAY_PER_REQUEST billing (free-tier safe)     │  │
│  └──────────────────────────────────────────────────┘  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Directory Structure

```
aws_tf_cicd/
├── provider.tf              # AWS provider and backend configuration
├── variables.tf             # Input variables
├── outputs.tf               # Output values
├── iam.tf                   # IAM user and policies
├── vpc.tf                   # VPC, subnets, security groups
├── ec2.tf                   # EC2 instance
├── s3.tf                    # Application S3 bucket
├── backend.tf               # Terraform state backend (S3 + DynamoDB)
├── terraform.tfvars.example # Example variables file
├── tfstate.config           # Backend configuration
├── .gitlab-ci.yml           # GitLab CI/CD pipeline
└── README.md                # This file
```

## Prerequisites

### Local Development
- Terraform >= 1.0
- AWS CLI configured with credentials
- Git for version control

### GitLab CI/CD
- GitLab project with CI/CD enabled
- AWS credentials stored as CI/CD variables:
  - `MY_AWS_KEY`: AWS Access Key ID
  - `MY_AWS_ACCESS_KEY`: AWS Secret Access Key
  - `APP_S3_BUCKET_NAME`: Unique S3 bucket name

## Setup Instructions

### 1. Clone and Configure

```bash
git clone <repository-url>
cd aws_tf_cicd
```

### 2. Create terraform.tfvars

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:
```hcl
region                = "us-east-1"
environment           = "dev"
ec2_ami_id            = "ami-0440d3b780d96b29d"
ec2_instance_type     = "t2.micro"
s3_bucket_name        = "app-data-bucket-unique-name"
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidr    = "10.0.1.0/24"
allowed_ssh_cidr      = "0.0.0.0/0"
```

### 3. Initialize Terraform

```bash
terraform init -backend-config="tfstate.config"
```

### 4. Validate Configuration

```bash
terraform validate
terraform fmt -recursive
```

### 5. Plan Deployment

```bash
terraform plan -out="planfile"
```

### 6. Apply Configuration

```bash
terraform apply "planfile"
```

## GitLab CI/CD Pipeline

The `.gitlab-ci.yml` defines a complete CI/CD workflow:

### Stages

1. **validate**: Syntax and format validation
2. **plan**: Generate execution plan
3. **apply**: Deploy infrastructure (manual approval)
4. **destroy**: Tear down infrastructure (manual approval)

### Environment Variables

Set these in GitLab CI/CD settings:

| Variable | Description |
|----------|-------------|
| `MY_AWS_KEY` | AWS Access Key ID |
| `MY_AWS_ACCESS_KEY` | AWS Secret Access Key |
| `APP_S3_BUCKET_NAME` | Unique S3 bucket name |

### Pipeline Execution

```
Commit → Validate → Plan → Apply (manual) → Destroy (manual)
```

## Resource Details

### IAM User: dnsec

**Policies:**
- EC2 Full Management (`ec2:*`)
- S3 Full Management (`s3:*`)
- IAM Read Access (limited to dnsec user)

**Access Keys:**
- Managed via Terraform
- Reference existing keys through variables

### EC2 Instance

- **Type**: t2.micro (free-tier eligible)
- **AMI**: Configurable via `ec2_ami_id` variable
- **VPC**: Default VPC with custom CIDR
- **Public IP**: Automatically assigned
- **Security Group**: SSH access only (port 22)

### S3 Buckets

**Application Bucket:**
- Server-side encryption (AES256)
- Public access blocked
- Versioning enabled
- Ownership controls configured

**Terraform State Bucket:**
- Encrypted with AES256
- Versioning enabled
- Public access blocked
- Account ID appended to bucket name for uniqueness

### DynamoDB Table

- **Name**: terraform-locks
- **Billing**: PAY_PER_REQUEST (free-tier safe)
- **Purpose**: State locking to prevent concurrent applies

## Cost Considerations

All resources are configured for AWS Free Tier:

✅ **Free-Tier Eligible:**
- EC2 t2.micro instance (750 hours/month)
- S3 storage (5 GB)
- DynamoDB on-demand (25 GB storage, 25 units read/write)
- Data transfer (1 GB/month outbound)

❌ **Avoid:**
- NAT Gateway (not included)
- Load Balancer (not included)
- Paid instance types
- Excessive data transfer

## Outputs

After applying, retrieve outputs:

```bash
terraform output
```

Key outputs:
- `ec2_instance_public_ip`: SSH access point
- `s3_bucket_name`: Application data bucket
- `iam_user_name`: dnsec user name
- `terraform_state_bucket`: Backend bucket name

## SSH Access

```bash
ssh -i <key-pair> ec2-user@<public-ip>
```

## Troubleshooting

### Backend Initialization Fails

Ensure the backend S3 bucket and DynamoDB table exist:

```bash
terraform init -backend-config="tfstate.config" -reconfigure
```

### State Lock Issues

If locked, check DynamoDB:

```bash
aws dynamodb scan --table-name terraform-locks --region us-east-1
```

### Destroy Fails

Ensure S3 buckets are empty before destroying:

```bash
aws s3 rm s3://<bucket-name> --recursive
```

## Security Best Practices

1. **Never commit credentials** to version control
2. **Use AWS IAM roles** for EC2 instances in production
3. **Restrict SSH CIDR** to known IPs (not 0.0.0.0/0)
4. **Enable MFA** for AWS account
5. **Rotate access keys** regularly
6. **Use Terraform Cloud** for state management in production

## Maintenance

### Update Terraform

```bash
terraform version
terraform init -upgrade
```

### Refresh State

```bash
terraform refresh
```

### Destroy Infrastructure

```bash
terraform destroy
```

## Contributing

1. Create a feature branch
2. Make changes and validate
3. Submit merge request
4. Pipeline runs automatically
5. Manual approval for apply/destroy

## License

MIT License - See LICENSE file

## Support

For issues or questions, refer to:
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform State Management](https://www.terraform.io/language/state)
