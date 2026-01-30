# AWS Terraform Infrastructure - Complete Setup Procedure

**Time Required**: 30 minutes  
**Difficulty**: Beginner-friendly  
**Cost**: $0 (AWS Free Tier)

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Step 1: Prepare AWS Account](#step-1-prepare-aws-account)
3. [Step 2: Install Required Tools](#step-2-install-required-tools)
4. [Step 3: Configure AWS Credentials](#step-3-configure-aws-credentials)
5. [Step 4: Prepare Terraform Variables](#step-4-prepare-terraform-variables)
6. [Step 5: Validate Setup](#step-5-validate-setup)
7. [Step 6: Deploy Infrastructure](#step-6-deploy-infrastructure)
8. [Step 7: Verify Deployment](#step-7-verify-deployment)
9. [Security Considerations](#security-considerations)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required
- AWS account (free tier eligible)
- Windows, macOS, or Linux system
- Administrator access to your computer
- Internet connection

### Knowledge
- Basic command line usage
- Understanding of AWS concepts (optional but helpful)

---

## Step 1: Prepare AWS Account

### 1.1 Create IAM User for Terraform

**Why**: Never use root AWS account credentials. Create a dedicated IAM user with limited permissions.

**Steps**:
1. Go to [AWS Console](https://console.aws.amazon.com)
2. Navigate to **IAM** → **Users**
3. Click **Create user**
4. Enter username: `terraform-user`
5. Click **Next**
6. Click **Attach policies directly**
7. Search and select these policies:
   - `IAMFullAccess`
   - `EC2FullAccess`
   - `S3FullAccess`
   - `DynamoDBFullAccess`
8. Click **Next** → **Create user**

### 1.2 Create Access Keys

**Why**: Access keys allow Terraform to authenticate with AWS.

**Steps**:
1. Click on the newly created `terraform-user`
2. Go to **Security credentials** tab
3. Click **Create access key**
4. Select **Command Line Interface (CLI)**
5. Check the acknowledgment box
6. Click **Create access key**
7. **IMPORTANT**: Copy and save both:
   - Access Key ID (starts with `AKIA`)
   - Secret Access Key (long random string)
8. Click **Done**

⚠️ **Security Note**: The secret key is only shown once. Save it immediately in a secure location.

---

## Step 2: Install Required Tools

### 2.1 Install Terraform

**Windows**:
```powershell
# Using Chocolatey (if installed)
choco install terraform

# Or download manually from:
# https://www.terraform.io/downloads
```

**macOS**:
```bash
brew install terraform
```

**Linux (Ubuntu/Debian)**:
```bash
sudo apt-get update
sudo apt-get install terraform
```

**Verify Installation**:
```bash
terraform --version
```

### 2.2 Install AWS CLI

**Windows**:
```powershell
# Using Chocolatey
choco install awscli

# Or download from:
# https://aws.amazon.com/cli/
```

**macOS**:
```bash
brew install awscli
```

**Linux (Ubuntu/Debian)**:
```bash
sudo apt-get install awscli
```

**Verify Installation**:
```bash
aws --version
```

### 2.3 Install Git (Optional but Recommended)

**Windows**:
```powershell
choco install git
```

**macOS**:
```bash
brew install git
```

**Linux (Ubuntu/Debian)**:
```bash
sudo apt-get install git
```

---

## Step 3: Configure AWS Credentials

### 3.1 Configure AWS CLI

**Command**:
```bash
aws configure
```

**When Prompted, Enter**:
```
AWS Access Key ID [None]: AKIA...
AWS Secret Access Key [None]: wJal...
Default region name [None]: us-east-1
Default output format [None]: json
```

**What This Does**:
- Creates `~/.aws/credentials` file (stores credentials securely)
- Creates `~/.aws/config` file (stores region and format)
- Credentials are NOT stored in version control

### 3.2 Verify Configuration

**Command**:
```bash
aws sts get-caller-identity
```

**Expected Output**:
```json
{
    "UserId": "AIDAI...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-user"
}
```

✅ If you see this output, credentials are configured correctly.

---

## Step 4: Prepare Terraform Variables

### 4.1 Clone Repository

```bash
git clone <repository-url>
cd aws_tf_cicd
```

### 4.2 Create terraform.tfvars File

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 4.3 Edit terraform.tfvars

Open `terraform.tfvars` in your text editor and update:

```hcl
# ============================================
# REQUIRED - MUST CHANGE THIS
# ============================================

# S3 bucket name - MUST BE GLOBALLY UNIQUE
# Add timestamp or random string to ensure uniqueness
s3_bucket_name = "app-data-bucket-1234567890"

# Examples of unique names:
# s3_bucket_name = "app-data-bucket-$(date +%s)"
# s3_bucket_name = "my-company-app-bucket-20240115"
# s3_bucket_name = "deepak-app-bucket-12345"


# ============================================
# OPTIONAL - Can keep defaults
# ============================================

# AWS region (default: us-east-1)
region = "us-east-1"

# Environment name (default: dev)
environment = "dev"

# EC2 AMI ID (default: Ubuntu 22.04 LTS)
ec2_ami_id = "ami-0440d3b780d96b29d"

# EC2 instance type (default: t2.micro - FREE TIER)
# DO NOT CHANGE - other types incur charges
ec2_instance_type = "t2.micro"

# VPC CIDR block (default: 10.0.0.0/16)
vpc_cidr = "10.0.0.0/16"

# Public subnet CIDR (default: 10.0.1.0/24)
public_subnet_cidr = "10.0.1.0/24"

# SSH access CIDR (default: 0.0.0.0/0 - OPEN TO ALL)
# For security, restrict to your IP: "YOUR_IP/32"
# Find your IP: curl https://checkip.amazonaws.com
allowed_ssh_cidr = "0.0.0.0/0"
```

### 4.4 Verify terraform.tfvars

```bash
# Check the file
cat terraform.tfvars

# Verify no credentials are in the file
grep -i "AKIA\|aws_secret" terraform.tfvars
# Should return nothing
```

---

## Step 5: Validate Setup

### 5.1 Run Validation Script

**Windows**:
```powershell
.\validate-setup.bat
```

**macOS/Linux**:
```bash
chmod +x validate-setup.bat
./validate-setup.bat
```

### 5.2 Check Output

The script will verify:
- ✓ Terraform installed
- ✓ AWS CLI installed
- ✓ AWS credentials configured
- ✓ AWS permissions available
- ✓ Terraform files present
- ✓ terraform.tfvars created
- ✓ No credentials in files

**Expected Result**: All checks should pass (green checkmarks)

---

## Step 6: Deploy Infrastructure

### 6.1 Initialize Terraform

```bash
terraform init -backend-config="tfstate.config"
```

**What This Does**:
- Downloads Terraform AWS provider
- Configures S3 backend for state management
- Creates `.terraform` directory

**Expected Output**:
```
Initializing the backend...
Successfully configured the backend "s3"!
Initializing provider plugins...
Terraform has been successfully initialized!
```

### 6.2 Validate Configuration

```bash
terraform validate
```

**Expected Output**:
```
Success! The configuration is valid.
```

### 6.3 Plan Deployment

```bash
terraform plan -out="planfile"
```

**What This Does**:
- Shows all resources that will be created
- Saves plan to `planfile` for later use
- Does NOT create any resources yet

**Review the Output**:
- Check resource count (should be 15)
- Verify resource names and configurations
- Look for any errors or warnings

### 6.4 Apply Configuration

```bash
terraform apply "planfile"
```

**What This Does**:
- Creates all AWS resources
- Updates Terraform state file
- Displays outputs with resource details

**Expected Time**: 2-3 minutes

**Expected Output**:
```
Apply complete! Resources: 15 added, 0 changed, 0 destroyed.

Outputs:
ec2_instance_public_ip = "54.123.45.67"
iam_user_name = "dnsec"
s3_bucket_name = "app-data-bucket-1234567890"
...
```

---

## Step 7: Verify Deployment

### 7.1 Check Terraform Outputs

```bash
terraform output
```

**Should Display**:
- EC2 instance public IP
- S3 bucket names
- IAM user name
- DynamoDB table name
- VPC ID

### 7.2 Verify in AWS Console

**EC2 Instance**:
1. Go to AWS Console → EC2 → Instances
2. Should see instance named `app-server`
3. Status should be `running`
4. Should have public IP address

**S3 Buckets**:
1. Go to AWS Console → S3
2. Should see 2 buckets:
   - `app-data-bucket-*` (application bucket)
   - `terraform-state-backend-*` (state bucket)

**IAM User**:
1. Go to AWS Console → IAM → Users
2. Should see user named `dnsec`
3. Should have 3 policies attached

**DynamoDB Table**:
1. Go to AWS Console → DynamoDB → Tables
2. Should see table named `terraform-locks`
3. Status should be `ACTIVE`

### 7.3 Test EC2 Connectivity (Optional)

```bash
# Get instance IP
terraform output ec2_instance_public_ip

# SSH into instance (if you have SSH key pair)
ssh -i your-key.pem ec2-user@<public-ip>
```

---

## Security Considerations

### 🔐 Credentials Management

**DO**:
- ✅ Use AWS CLI for credentials (`aws configure`)
- ✅ Store credentials in `~/.aws/credentials`
- ✅ Use IAM users instead of root account
- ✅ Rotate access keys regularly (every 90 days)
- ✅ Use strong, unique passwords

**DON'T**:
- ❌ Hardcode credentials in `terraform.tfvars`
- ❌ Commit credentials to Git
- ❌ Share AWS credentials with anyone
- ❌ Use root account credentials
- ❌ Store credentials in plain text files

### 🔒 Network Security

**SSH Access**:
- Default: `0.0.0.0/0` (open to entire internet)
- Recommended: Restrict to your IP: `YOUR_IP/32`
- Find your IP: `curl https://checkip.amazonaws.com`

**S3 Buckets**:
- ✅ Public access blocked
- ✅ Encryption enabled (AES256)
- ✅ Versioning enabled
- ✅ No public URLs

**VPC**:
- ✅ Isolated network (10.0.0.0/16)
- ✅ Single public subnet
- ✅ Security group restricts traffic
- ✅ Internet Gateway for controlled access

### 🛡️ IAM Security

**dnsec User**:
- ✅ Least-privilege policies
- ✅ EC2 full access (scoped to EC2)
- ✅ S3 full access (scoped to S3)
- ✅ IAM read access (limited to self)

**Best Practices**:
- ✅ Use IAM roles for EC2 instances (in production)
- ✅ Enable MFA on AWS account
- ✅ Use CloudTrail for audit logging
- ✅ Review IAM policies regularly

### 🔑 State File Security

**Terraform State**:
- ✅ Stored in S3 (encrypted with AES256)
- ✅ Versioning enabled (can recover previous states)
- ✅ DynamoDB locking (prevents concurrent modifications)
- ✅ Public access blocked

**Best Practices**:
- ✅ Never commit state files to Git
- ✅ Use remote backends (S3 + DynamoDB)
- ✅ Enable state file encryption
- ✅ Restrict access to state bucket

### 💰 Cost Security

**Free Tier Limits**:
- EC2 t2.micro: 750 hours/month
- S3: 5 GB storage
- DynamoDB: 25 GB storage, 25 RCU/WCU
- Data transfer: 1 GB/month outbound

**Cost Prevention**:
- ✅ Use only free-tier eligible resources
- ✅ Don't change EC2 instance type
- ✅ Monitor AWS billing dashboard
- ✅ Set up billing alerts

---

## Troubleshooting

### Issue: "terraform: command not found"

**Solution**:
```bash
# Verify installation
terraform --version

# If not found, reinstall:
# Windows: choco install terraform
# macOS: brew install terraform
# Linux: sudo apt-get install terraform
```

### Issue: "AWS credentials not configured"

**Solution**:
```bash
# Configure credentials
aws configure

# Verify configuration
aws sts get-caller-identity
```

### Issue: "S3 bucket name already exists"

**Solution**:
- S3 bucket names must be globally unique
- Edit `terraform.tfvars` and add timestamp or random string
- Example: `app-data-bucket-$(date +%s)`

### Issue: "terraform init fails"

**Solution**:
```bash
# Reinitialize with reconfigure flag
terraform init -backend-config="tfstate.config" -reconfigure

# Or migrate state
terraform init -migrate-state
```

### Issue: "Insufficient permissions"

**Solution**:
- Verify IAM user has required policies:
  - IAMFullAccess
  - EC2FullAccess
  - S3FullAccess
  - DynamoDBFullAccess
- Run validation script to check permissions

### Issue: "terraform apply fails"

**Solution**:
1. Check error message carefully
2. Verify AWS credentials are valid
3. Check AWS service limits
4. Verify region is correct (us-east-1)
5. Run `terraform plan` to see what would happen

### Issue: "EC2 instance not accessible"

**Solution**:
```bash
# Check instance status
aws ec2 describe-instance-status --instance-ids <instance-id>

# Check security group
aws ec2 describe-security-groups --group-ids <sg-id>

# Verify SSH key permissions
chmod 400 your-key.pem
```

---

## Next Steps

### Immediate
1. ✅ Verify all resources in AWS Console
2. ✅ Test EC2 connectivity
3. ✅ Upload test files to S3

### Short-term
1. ✅ Set up GitLab CI/CD (optional)
2. ✅ Configure monitoring
3. ✅ Document customizations

### Long-term
1. ✅ Plan scaling strategy
2. ✅ Implement backup procedures
3. ✅ Set up disaster recovery

---

## Summary

**What You've Done**:
- ✅ Created AWS IAM user with limited permissions
- ✅ Generated and configured AWS credentials
- ✅ Installed Terraform and AWS CLI
- ✅ Prepared Terraform variables
- ✅ Validated setup
- ✅ Deployed 15 AWS resources
- ✅ Verified deployment

**What You Have**:
- ✅ VPC with public subnet
- ✅ EC2 instance (t2.micro)
- ✅ 2 S3 buckets (app + state)
- ✅ IAM user with policies
- ✅ DynamoDB lock table
- ✅ Remote state management

**Cost**: $0 (AWS Free Tier)

**Time**: ~30 minutes

---

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review README.md for architecture details
3. Check VALIDATE_SETUP_EXPLAINED.md for validation details
4. Consult [Terraform Documentation](https://www.terraform.io/docs)
5. Consult [AWS Documentation](https://docs.aws.amazon.com)

---