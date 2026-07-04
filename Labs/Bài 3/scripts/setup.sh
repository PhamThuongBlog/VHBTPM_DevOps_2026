#!/bin/bash
# ============================================================
# setup.sh — Script cài đặt môi trường Lab 3 (macOS/Linux)
# ============================================================
# Usage: bash setup.sh

set -e

echo "==============================================="
echo "  Lab 3 - Cài đặt Môi trường Terraform + AWS"
echo "==============================================="
echo ""

# --- 1. Detect OS ---
OS="$(uname -s)"
echo "[1/4] Hệ điều hành: $OS"

# --- 2. Cài đặt Terraform ---
echo "[2/4] Cài đặt Terraform..."

if command -v terraform &> /dev/null; then
    echo "Terraform đã có sẵn: $(terraform version | head -1)"
else
    case "$OS" in
        Darwin)
            echo "Cài đặt qua Homebrew..."
            brew tap hashicorp/tap
            brew install hashicorp/tap/terraform
            ;;
        Linux)
            echo "Cài đặt qua apt..."
            wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
            echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
            sudo apt update && sudo apt install -y terraform
            ;;
    esac
    echo "Terraform đã cài đặt xong."
fi

# --- 3. Cài đặt AWS CLI ---
echo "[3/4] Cài đặt AWS CLI..."

if command -v aws &> /dev/null; then
    echo "AWS CLI đã có sẵn: $(aws --version)"
else
    case "$OS" in
        Darwin)
            brew install awscli
            ;;
        Linux)
            curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
            unzip -o /tmp/awscliv2.zip -d /tmp/
            sudo /tmp/aws/install
            rm -f /tmp/awscliv2.zip
            ;;
    esac
    echo "AWS CLI đã cài đặt xong."
fi

# --- 4. Kiểm tra kết quả ---
echo "[4/4] Kiểm tra cài đặt..."
echo ""
echo "Terraform version:"
terraform version
echo ""
echo "AWS CLI version:"
aws --version
echo ""

# --- Hướng dẫn tiếp theo ---
echo "==============================================="
echo "  CÀI ĐẶT HOÀN TẤT!"
echo "==============================================="
echo ""
echo "Tiếp theo, hãy cấu hình AWS credentials:"
echo "  aws configure"
echo ""
echo "Sau đó vào thư mục configs và bắt đầu lab:"
echo "  cd configs"
echo "  terraform init"
