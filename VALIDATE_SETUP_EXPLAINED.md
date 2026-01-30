# Validation Script Explained - How validate-setup.bat Works

**Purpose**: Verify that all prerequisites are installed and configured correctly before deployment.

**File**: `validate-setup.bat`

**Platform**: Windows (Command Prompt / PowerShell)

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [What the Script Does](#what-the-script-does)
3. [Section-by-Section Breakdown](#section-by-section-breakdown)
4. [Understanding the Output](#understanding-the-output)
5. [How to Run](#how-to-run)
6. [Interpreting Results](#interpreting-results)

---

## Overview

The validation script is a batch file that automatically checks:
- ✓ Required tools installed (Terraform, AWS CLI, Git)
- ✓ AWS credentials configured
- ✓ AWS permissions available
- ✓ Terraform files present
- ✓ Configuration files created
- ✓ No sensitive data exposed
- ✓ Git configuration (optional)

**Why Use It?**
- Saves time by checking everything at once
- Prevents deployment errors
- Identifies missing prerequisites
- Ensures security best practices

---

## What the Script Does

### High-Level Flow

```
START
  ↓
Check Prerequisites (Terraform, AWS CLI, Git)
  ↓
Check AWS Credentials
  ↓
Check AWS Permissions (IAM, EC2, S3, DynamoDB)
  ↓
Check Terraform Files
  ↓
Check Configuration Files
  ↓
Check Documentation
  ↓
Check Terraform Initialization
  ↓
Check Git Configuration
  ↓
Check for Sensitive Data
  ↓
Display Summary
  ↓
END
```

---

## Section-by-Section Breakdown

### 1. Header and Initialization

```batch
@echo off
REM AWS Terraform Infrastructure - Setup Validation Script (Windows)
REM This script validates that all prerequisites are installed and configured

setlocal enabledelayedexpansion
```

**What It Does**:
- `@echo off` - Hides command echoing (cleaner output)
- `setlocal enabledelayedexpansion` - Enables variable expansion in loops
- `REM` - Comments (ignored by script)

**Why**: Makes output readable and allows variable manipulation

---

### 2. Initialize Counters

```batch
set PASSED=0
set FAILED=0
set WARNINGS=0
```

**What It Does**:
- Creates three counters to track results
- `PASSED` - Counts successful checks
- `FAILED` - Counts failed checks
- `WARNINGS` - Counts warnings

**Why**: Provides summary statistics at the end

---

### 3. Check Prerequisites

```batch
where terraform >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] Terraform installed
    set /a PASSED+=1
) else (
    echo [FAIL] Terraform not installed
    set /a FAILED+=1
)
```

**What It Does**:
- `where terraform` - Searches for Terraform in system PATH
- `>nul 2>nul` - Suppresses output (redirects to null)
- `%ERRORLEVEL%` - Checks if command succeeded (0 = success)
- `if` statement - Evaluates result
- `set /a PASSED+=1` - Increments counter

**Why**: Verifies Terraform is installed and accessible

**Same Process For**:
- AWS CLI (`where aws`)
- Git (`where git`)

---

### 4. Check AWS Credentials

```batch
aws sts get-caller-identity >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] AWS credentials configured
    set /a PASSED+=1
    
    for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Account --output text') do (
        echo     Account ID: %%i
    )
) else (
    echo [FAIL] AWS credentials not configured or invalid
    set /a FAILED+=1
)
```

**What It Does**:
- `aws sts get-caller-identity` - Calls AWS to verify credentials
- `for /f` loop - Extracts Account ID from AWS response
- `%%i` - Loop variable (holds Account ID)
- Displays Account ID if successful

**Why**: Confirms AWS credentials are valid and working

---

### 5. Check AWS Permissions

```batch
aws iam get-user >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] IAM permissions available
    set /a PASSED+=1
) else (
    echo [WARN] IAM permissions may be limited
    set /a WARNINGS+=1
)
```

**What It Does**:
- `aws iam get-user` - Calls AWS IAM service
- If successful → IAM permissions available
- If fails → Permissions may be limited

**Same Process For**:
- EC2 permissions (`aws ec2 describe-instances`)
- S3 permissions (`aws s3 ls`)
- DynamoDB permissions (`aws dynamodb list-tables`)

**Why**: Verifies IAM user has required permissions

---

### 6. Check Terraform Files

```batch
for %%f in (provider.tf variables.tf outputs.tf iam.tf vpc.tf ec2.tf s3.tf backend.tf) do (
    if exist "%%f" (
        echo [OK] Found: %%f
        set /a PASSED+=1
    ) else (
        echo [FAIL] Missing: %%f
        set /a FAILED+=1
    )
)
```

**What It Does**:
- `for` loop - Iterates through list of files
- `%%f` - Loop variable (holds filename)
- `if exist` - Checks if file exists
- Increments counter based on result

**Why**: Ensures all required Terraform files are present

---

### 7. Check Configuration Files

```batch
if exist "terraform.tfvars" (
    echo [OK] terraform.tfvars exists
    set /a PASSED+=1
) else if exist "terraform.tfvars.example" (
    echo [WARN] terraform.tfvars not found (copy from terraform.tfvars.example)
    set /a WARNINGS+=1
) else (
    echo [FAIL] terraform.tfvars.example not found
    set /a FAILED+=1
)
```

**What It Does**:
- Checks if `terraform.tfvars` exists
- If not, checks if example file exists
- Provides helpful message if example exists
- Fails if neither exists

**Why**: Ensures configuration file is ready

---

### 8. Check for Sensitive Data

```batch
REM This section would search for credentials in files
REM (Not shown in detail for security reasons)
```

**What It Does**:
- Searches for AWS access keys in Terraform files
- Searches for hardcoded secrets
- Warns if credentials found

**Why**: Prevents accidental credential exposure

---

### 9. Display Summary

```batch
set /a TOTAL=PASSED+FAILED+WARNINGS
echo Total Checks: !TOTAL!
echo Passed: !PASSED!
echo Failed: !FAILED!
echo Warnings: !WARNINGS!
```

**What It Does**:
- Calculates total checks
- Displays summary statistics
- Uses `!TOTAL!` (delayed expansion) for accurate calculation

**Why**: Provides quick overview of validation results

---

### 10. Determine Success/Failure

```batch
if !FAILED! equ 0 (
    echo [SUCCESS] All critical checks passed!
    if !WARNINGS! gtr 0 (
        echo [WARNING] Please address the warnings above
    )
    exit /b 0
) else (
    echo [FAILURE] Some checks failed. Please fix the issues above.
    exit /b 1
)
```

**What It Does**:
- Checks if any checks failed
- If no failures → Success
- If failures exist → Failure
- `exit /b 0` - Returns success code
- `exit /b 1` - Returns failure code

**Why**: Allows script to be used in automated workflows

---

## Understanding the Output

### Output Format

```
[OK]   - Check passed successfully
[FAIL] - Check failed (critical issue)
[WARN] - Check passed with warning (non-critical)
```

### Example Output

```
=== Checking Prerequisites ===

[OK] Terraform installed: Terraform v1.5.0
[OK] AWS CLI installed: aws-cli/2.13.0
[OK] Git installed: git version 2.42.0

=== Checking AWS Credentials ===

[OK] AWS credentials configured
    Account ID: 123456789012
    User ARN: arn:aws:iam::123456789012:user/terraform-user

=== Checking AWS Permissions ===

[OK] IAM permissions available
[OK] EC2 permissions available
[OK] S3 permissions available
[OK] DynamoDB permissions available

=== Validation Summary ===

Total Checks: 25
Passed: 23
Failed: 0
Warnings: 2

[SUCCESS] All critical checks passed!
[WARNING] Please address the warnings above
```

---

## How to Run

### Windows Command Prompt

```cmd
cd aws_tf_cicd
validate-setup.bat
```

### Windows PowerShell

```powershell
cd aws_tf_cicd
.\validate-setup.bat
```

### Expected Behavior

1. Script starts
2. Displays header
3. Runs all checks
4. Displays results for each check
5. Shows summary
6. Exits with success (0) or failure (1)

---

## Interpreting Results

### All Checks Passed ✅

```
[SUCCESS] All critical checks passed!
```

**Meaning**: You're ready to deploy!

**Next Step**: Run `terraform init -backend-config="tfstate.config"`

---

### Some Checks Failed ❌

```
[FAILURE] Some checks failed. Please fix the issues above.
```

**Meaning**: Prerequisites are missing or misconfigured

**Common Issues**:

| Issue | Solution |
|-------|----------|
| Terraform not installed | Install Terraform |
| AWS CLI not installed | Install AWS CLI |
| AWS credentials not configured | Run `aws configure` |
| terraform.tfvars not found | Run `cp terraform.tfvars.example terraform.tfvars` |
| Insufficient permissions | Add required IAM policies |

---

### Warnings Present ⚠️

```
[WARNING] Please address the warnings above
```

**Meaning**: Non-critical issues that should be addressed

**Common Warnings**:

| Warning | Action |
|---------|--------|
| Git user not configured | Run `git config user.name "Your Name"` |
| Git email not configured | Run `git config user.email "your@email.com"` |
| Terraform not initialized | Run `terraform init` |
| Documentation files missing | Not critical, but helpful |

---

## Key Checks Explained

### 1. Terraform Installation

**Why Important**: Terraform is required to deploy infrastructure

**What It Checks**: Is Terraform in system PATH?

**If Fails**: Install Terraform from https://www.terraform.io/downloads

---

### 2. AWS CLI Installation

**Why Important**: AWS CLI is used to configure credentials

**What It Checks**: Is AWS CLI in system PATH?

**If Fails**: Install AWS CLI from https://aws.amazon.com/cli/

---

### 3. AWS Credentials

**Why Important**: Terraform needs credentials to authenticate with AWS

**What It Checks**: Can AWS CLI authenticate successfully?

**If Fails**: Run `aws configure` and enter credentials

---

### 4. AWS Permissions

**Why Important**: IAM user needs specific permissions to create resources

**What It Checks**: Can IAM user access IAM, EC2, S3, DynamoDB?

**If Fails**: Add required policies to IAM user:
- IAMFullAccess
- EC2FullAccess
- S3FullAccess
- DynamoDBFullAccess

---

### 5. Terraform Files

**Why Important**: All Terraform files must be present

**What It Checks**: Do all 8 Terraform files exist?

**If Fails**: Ensure all files are in `aws_tf_cicd/` directory

---

### 6. Configuration Files

**Why Important**: terraform.tfvars is required for deployment

**What It Checks**: Does terraform.tfvars exist?

**If Fails**: Run `cp terraform.tfvars.example terraform.tfvars`

---

### 7. Sensitive Data

**Why Important**: Credentials should never be in version control

**What It Checks**: Are AWS credentials in Terraform files?

**If Fails**: Remove credentials from terraform.tfvars

---

## Troubleshooting the Validation Script

### Script Won't Run

**Problem**: "validate-setup.bat is not recognized"

**Solution**:
```cmd
# Navigate to correct directory
cd aws_tf_cicd

# Run script
validate-setup.bat
```

---

### Script Hangs

**Problem**: Script appears to freeze

**Solution**:
- Press Ctrl+C to stop
- Check internet connection
- Verify AWS credentials are correct
- Try running individual commands manually

---

### Unexpected Errors

**Problem**: Script shows errors not listed above

**Solution**:
1. Read error message carefully
2. Search for error in AWS documentation
3. Check AWS service status
4. Verify IAM permissions

---

## What Happens After Validation

### If All Checks Pass

1. Run: `terraform init -backend-config="tfstate.config"`
2. Run: `terraform validate`
3. Run: `terraform plan -out="planfile"`
4. Run: `terraform apply "planfile"`

### If Checks Fail

1. Fix the issues listed
2. Run validation script again
3. Repeat until all checks pass
4. Then proceed with deployment

---

## Security Aspects of Validation

### What the Script Checks for Security

✅ **Credentials Not Exposed**
- Searches for AWS access keys in files
- Searches for hardcoded secrets
- Warns if credentials found

✅ **Permissions Verified**
- Confirms IAM user has required permissions
- Checks each AWS service separately
- Identifies permission gaps

✅ **Configuration Correct**
- Verifies terraform.tfvars exists
- Checks for required files
- Ensures proper setup

### What the Script Does NOT Check

❌ **Network Security**
- Doesn't verify security group rules
- Doesn't check SSH CIDR restrictions
- Doesn't validate VPC configuration

❌ **AWS Account Security**
- Doesn't check MFA status
- Doesn't verify CloudTrail logging
- Doesn't check password policies

❌ **Credential Rotation**
- Doesn't check access key age
- Doesn't verify key rotation schedule
- Doesn't check for unused keys

---

## Summary

**What the Script Does**:
- Verifies all prerequisites are installed
- Confirms AWS credentials are configured
- Checks AWS permissions are sufficient
- Ensures all required files are present
- Detects security issues
- Provides clear pass/fail/warning results

**Why Use It**:
- Saves time by checking everything at once
- Prevents deployment errors
- Identifies missing prerequisites
- Ensures security best practices
- Provides clear guidance on fixes

**When to Run It**:
- Before first deployment
- After installing new tools
- After changing AWS credentials
- When troubleshooting deployment issues
- As part of CI/CD pipeline

**Expected Time**: 30-60 seconds

---

## Next Steps

After validation passes:

1. **Initialize Terraform**
   ```bash
   terraform init -backend-config="tfstate.config"
   ```

2. **Plan Deployment**
   ```bash
   terraform plan -out="planfile"
   ```

3. **Deploy Infrastructure**
   ```bash
   terraform apply "planfile"
   ```

4. **Verify Deployment**
   ```bash
   terraform output
   ```

---

**Status**: ✅ Validation Script Ready to Use

**Next**: Run the script and follow the guidance in PROCEDURE.md for deployment.
