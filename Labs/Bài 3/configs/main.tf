# ============================================================
# main.tf — Cấu hình chính: Provider + Resources
# Lab 3: IaC với Terraform & AWS
# ============================================================

# ----- 1. Cấu hình Provider AWS -----
provider "aws" {
  region = var.region
}

# ----- 2. Tạo EC2 Instance (máy chủ ảo) -----
resource "aws_instance" "lab_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  tags = {
    Name        = "Lab3-Terraform-Server"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Course      = "DevOps-Bai3"
  }
}

# ----- 3. Tạo Security Group (tường lửa) -----
resource "aws_security_group" "lab_sg" {
  name        = "lab3-terraform-sg"
  description = "Security Group cho Lab 3 - Cho phép SSH + HTTP"

  # Cho phép SSH
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cho phép HTTP
  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Cho phép tất cả traffic ra ngoài
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "Lab3-SG"
    ManagedBy = "Terraform"
  }
}

# ----- 4. Tạo S3 Bucket (lưu trữ) -----
resource "aws_s3_bucket" "lab_bucket" {
  bucket = "${var.s3_bucket_prefix}-${random_id.bucket_suffix.hex}"
}

# ----- 5. Random ID để tạo tên bucket unique -----
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# ----- 6. Cấu hình Versioning cho S3 -----
resource "aws_s3_bucket_versioning" "lab_bucket_versioning" {
  bucket = aws_s3_bucket.lab_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ----- 7. Cấu hình Encryption cho S3 -----
resource "aws_s3_bucket_server_side_encryption_configuration" "lab_bucket_encryption" {
  bucket = aws_s3_bucket.lab_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
