@echo off
REM AWS Terraform Infrastructure - Setup Validation Script (Windows)
REM This script validates that all prerequisites are installed and configured

setlocal enabledelayedexpansion

REM Initialize counters
set PASSED=0
set FAILED=0
set WARNINGS=0

REM Print header
echo.
echo ============================================================
echo   AWS Terraform Infrastructure - Setup Validation Script
echo ============================================================
echo.

REM Check prerequisites
echo === Checking Prerequisites ===
echo.

REM Check Terraform
where terraform >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('terraform version') do (
        echo [OK] Terraform installed: %%i
        set /a PASSED+=1
        goto :check_aws
    )
) else (
    echo [FAIL] Terraform not installed
    set /a FAILED+=1
)

:check_aws
REM Check AWS CLI
where aws >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('aws --version') do (
        echo [OK] AWS CLI installed: %%i
        set /a PASSED+=1
        goto :check_git
    )
) else (
    echo [FAIL] AWS CLI not installed
    set /a FAILED+=1
)

:check_git
REM Check Git
where git >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('git --version') do (
        echo [OK] Git installed: %%i
        set /a PASSED+=1
        goto :check_credentials
    )
) else (
    echo [FAIL] Git not installed
    set /a FAILED+=1
)

:check_credentials
echo.
echo === Checking AWS Credentials ===
echo.

REM Check AWS credentials
aws sts get-caller-identity >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] AWS credentials configured
    set /a PASSED+=1
    
    for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Account --output text') do (
        echo     Account ID: %%i
    )
    for /f "tokens=*" %%i in ('aws sts get-caller-identity --query Arn --output text') do (
        echo     User ARN: %%i
    )
    goto :check_permissions
) else (
    echo [FAIL] AWS credentials not configured or invalid
    set /a FAILED+=1
)

:check_permissions
echo.
echo === Checking AWS Permissions ===
echo.

REM Check IAM permissions
aws iam get-user >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] IAM permissions available
    set /a PASSED+=1
) else (
    echo [WARN] IAM permissions may be limited
    set /a WARNINGS+=1
)

REM Check EC2 permissions
aws ec2 describe-instances >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] EC2 permissions available
    set /a PASSED+=1
) else (
    echo [WARN] EC2 permissions may be limited
    set /a WARNINGS+=1
)

REM Check S3 permissions
aws s3 ls >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] S3 permissions available
    set /a PASSED+=1
) else (
    echo [WARN] S3 permissions may be limited
    set /a WARNINGS+=1
)

REM Check DynamoDB permissions
aws dynamodb list-tables >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo [OK] DynamoDB permissions available
    set /a PASSED+=1
) else (
    echo [WARN] DynamoDB permissions may be limited
    set /a WARNINGS+=1
)

echo.
echo === Checking Terraform Files ===
echo.

REM Check required Terraform files
for %%f in (provider.tf variables.tf outputs.tf iam.tf vpc.tf ec2.tf s3.tf backend.tf) do (
    if exist "%%f" (
        echo [OK] Found: %%f
        set /a PASSED+=1
    ) else (
        echo [FAIL] Missing: %%f
        set /a FAILED+=1
    )
)

echo.
echo === Checking Configuration Files ===
echo.

REM Check terraform.tfvars
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

REM Check tfstate.config
if exist "tfstate.config" (
    echo [OK] tfstate.config exists
    set /a PASSED+=1
) else (
    echo [FAIL] tfstate.config not found
    set /a FAILED+=1
)

REM Check .gitignore
if exist ".gitignore" (
    echo [OK] .gitignore exists
    set /a PASSED+=1
) else (
    echo [WARN] .gitignore not found
    set /a WARNINGS+=1
)

echo.
echo === Checking Documentation ===
echo.

REM Check documentation files
for %%d in (README.md SETUP_GUIDE.md ARCHITECTURE.md QUICK_REFERENCE.md PROJECT_SUMMARY.md DEPLOYMENT_CHECKLIST.md INDEX.md) do (
    if exist "%%d" (
        echo [OK] Found: %%d
        set /a PASSED+=1
    ) else (
        echo [WARN] Missing: %%d
        set /a WARNINGS+=1
    )
)

echo.
echo === Checking Terraform Initialization ===
echo.

REM Check .terraform directory
if exist ".terraform" (
    echo [OK] Terraform initialized (.terraform directory exists)
    set /a PASSED+=1
) else (
    echo [WARN] Terraform not initialized (run: terraform init -backend-config="tfstate.config")
    set /a WARNINGS+=1
)

REM Check .terraform.lock.hcl
if exist ".terraform.lock.hcl" (
    echo [OK] Terraform lock file exists
    set /a PASSED+=1
) else (
    echo [WARN] Terraform lock file not found
    set /a WARNINGS+=1
)

echo.
echo === Checking Git Configuration ===
echo.

REM Check Git user
git config user.name >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('git config user.name') do (
        echo [OK] Git user configured: %%i
        set /a PASSED+=1
    )
) else (
    echo [WARN] Git user not configured (run: git config user.name "Your Name")
    set /a WARNINGS+=1
)

REM Check Git email
git config user.email >nul 2>nul
if %ERRORLEVEL% equ 0 (
    for /f "tokens=*" %%i in ('git config user.email') do (
        echo [OK] Git email configured: %%i
        set /a PASSED+=1
    )
) else (
    echo [WARN] Git email not configured (run: git config user.email "your@email.com")
    set /a WARNINGS+=1
)

echo.
echo === Validation Summary ===
echo.

set /a TOTAL=PASSED+FAILED+WARNINGS
echo Total Checks: !TOTAL!
echo Passed: !PASSED!
echo Failed: !FAILED!
echo Warnings: !WARNINGS!

echo.
if !FAILED! equ 0 (
    echo [SUCCESS] All critical checks passed!
    if !WARNINGS! gtr 0 (
        echo [WARNING] Please address the warnings above
    )
    goto :next_steps
) else (
    echo [FAILURE] Some checks failed. Please fix the issues above.
    goto :error_steps
)

:next_steps
echo.
echo === Next Steps ===
echo.
echo 1. Review terraform.tfvars configuration
echo 2. Run: terraform validate
echo 3. Run: terraform plan -out="planfile"
echo 4. Review the plan output
echo 5. Run: terraform apply "planfile"
echo.
echo For more details, see:
echo   - README.md - Main documentation
echo   - SETUP_GUIDE.md - Step-by-step instructions
echo   - QUICK_REFERENCE.md - Command reference
echo.
exit /b 0

:error_steps
echo.
echo === Next Steps ===
echo.
echo Please fix the errors above before proceeding.
echo.
echo For help, see:
echo   - SETUP_GUIDE.md - Troubleshooting section
echo   - README.md - Prerequisites section
echo.
exit /b 1
