#!/bin/bash
# ============================================================
# cleanup.sh — Script dọn dẹp tài nguyên Lab 3
# ============================================================
# Usage: bash cleanup.sh
# Chạy để xóa toàn bộ tài nguyên AWS đã tạo trong lab

set -e

echo "==============================================="
echo "  CLEANUP — Dọn dẹp Tài nguyên Lab 3"
echo "==============================================="
echo ""

# --- Kiểm tra Terraform state ---
if [ ! -f "terraform.tfstate" ]; then
    echo "Không tìm thấy terraform.tfstate — không có gì để dọn dẹp."
    exit 0
fi

# --- Hiển thị tài nguyên sẽ bị xóa ---
echo "Các tài nguyên đang được Terraform quản lý:"
terraform state list
echo ""

# --- Xác nhận ---
echo "⚠️  CẢNH BÁO: Lệnh này sẽ XÓA TOÀN BỘ tài nguyên đã tạo!"
echo "   Bao gồm: EC2 instance, S3 bucket, Security Group..."
echo ""
read -p "Bạn có chắc muốn tiếp tục? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Đã hủy. Tài nguyên được giữ nguyên."
    exit 0
fi

# --- Destroy ---
echo ""
echo "Đang xóa tài nguyên..."
terraform destroy -auto-approve

echo ""
echo "==============================================="
echo "  DỌN DẸP HOÀN TẤT!"
echo "==============================================="
echo ""
echo "Kiểm tra xác nhận:"
terraform state list 2>/dev/null || echo "  (không còn tài nguyên nào)"
echo ""
echo "💡 Luôn chạy cleanup sau khi hoàn thành lab để tránh AWS tính phí!"
