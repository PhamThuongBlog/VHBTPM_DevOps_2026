#!/bin/bash
# ============================================================
# verify.sh — Script kiểm tra kết quả Lab 3
# ============================================================
# Usage: bash verify.sh
# Chạy sau khi terraform apply thành công

set -e

echo "==============================================="
echo "  VERIFY — Kiểm tra Kết quả Lab 3"
echo "==============================================="
echo ""

PASS_COUNT=0
FAIL_COUNT=0
TOTAL=0

check() {
    TOTAL=$((TOTAL + 1))
    local name="$1"
    local result="$2"
    echo -n "[$TOTAL] $name ... "
    if [ "$result" = "OK" ]; then
        echo "✅ PASS"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo "❌ FAIL — $result"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
}

# --- 1. Kiểm tra Terraform ---
if command -v terraform &> /dev/null; then
    check "Terraform installed" "OK"
else
    check "Terraform installed" "Terraform not found. Run setup.sh first."
fi

# --- 2. Kiểm tra AWS CLI ---
if command -v aws &> /dev/null; then
    check "AWS CLI installed" "OK"
else
    check "AWS CLI installed" "AWS CLI not found."
fi

# --- 3. Kiểm tra AWS credentials ---
if aws sts get-caller-identity &> /dev/null; then
    check "AWS credentials configured" "OK"
else
    check "AWS credentials configured" "Run: aws configure"
fi

# --- 4. Kiểm tra file .tf ---
if [ -f "main.tf" ] && [ -f "variables.tf" ] && [ -f "outputs.tf" ]; then
    check "Terraform config files (main.tf, variables.tf, outputs.tf)" "OK"
else
    check "Terraform config files" "Missing .tf files in current directory"
fi

# --- 5. Kiểm tra terraform init ---
if [ -d ".terraform" ]; then
    check "Terraform initialized (.terraform folder exists)" "OK"
else
    check "Terraform initialized" "Run: terraform init"
fi

# --- 6. Kiểm tra cú pháp ---
if terraform validate &> /dev/null; then
    check "Terraform validate" "OK"
else
    check "Terraform validate" "Run terraform validate to see errors"
fi

# --- 7. Kiểm tra state ---
if [ -f "terraform.tfstate" ]; then
    check "Terraform state file exists" "OK"
else
    check "Terraform state file exists" "Run terraform apply first"
fi

# --- 8. Kiểm tra resource trong state ---
EC2_COUNT=$(terraform state list 2>/dev/null | grep aws_instance | wc -l || echo "0")
S3_COUNT=$(terraform state list 2>/dev/null | grep aws_s3_bucket | wc -l || echo "0")
SG_COUNT=$(terraform state list 2>/dev/null | grep aws_security_group | wc -l || echo "0")

if [ "$EC2_COUNT" -ge 1 ]; then
    check "EC2 instance in Terraform state" "OK"
else
    check "EC2 instance in Terraform state" "No EC2 found — run terraform apply"
fi

if [ "$S3_COUNT" -ge 1 ]; then
    check "S3 bucket in Terraform state" "OK"
else
    check "S3 bucket in Terraform state" "No S3 bucket found — run terraform apply"
fi

if [ "$SG_COUNT" -ge 1 ]; then
    check "Security Group in Terraform state" "OK"
else
    check "Security Group in Terraform state" "No SG found — run terraform apply"
fi

# --- 9. Kiểm tra outputs ---
if terraform output ec2_public_ip &> /dev/null; then
    IP=$(terraform output -raw ec2_public_ip 2>/dev/null || echo "")
    if [ -n "$IP" ]; then
        check "EC2 Public IP: $IP" "OK"
    else
        check "EC2 Public IP" "Output is empty"
    fi
else
    check "EC2 Public IP output" "No output — run terraform apply"
fi

if terraform output s3_bucket_name &> /dev/null; then
    BUCKET=$(terraform output -raw s3_bucket_name 2>/dev/null || echo "")
    if [ -n "$BUCKET" ]; then
        check "S3 Bucket Name: $BUCKET" "OK"
    else
        check "S3 Bucket Name" "Output is empty"
    fi
else
    check "S3 Bucket Name output" "No output — run terraform apply"
fi

# --- Tổng kết ---
echo ""
echo "==============================================="
echo "  KẾT QUẢ: $PASS_COUNT/$TOTAL PASS, $FAIL_COUNT FAIL"
echo "==============================================="

if [ "$FAIL_COUNT" -eq 0 ]; then
    echo ""
    echo "🎉 Tất cả kiểm tra đều PASS! Lab hoàn thành tốt."
    echo ""
    echo "Đừng quên dọn dẹp tài nguyên:"
    echo "  terraform destroy"
else
    echo ""
    echo "⚠️  Còn $FAIL_COUNT lỗi cần khắc phục. Xem chi tiết ở trên."
fi
