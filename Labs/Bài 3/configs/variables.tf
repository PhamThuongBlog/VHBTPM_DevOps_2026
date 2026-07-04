# ============================================================
# variables.tf — Khai báo biến cho dự án Terraform AWS Lab
# ============================================================

# --- Region ---
variable "region" {
  description = "AWS region để triển khai tài nguyên"
  type        = string
  default     = "us-east-1"
}

# --- EC2 ---
variable "instance_type" {
  description = "Loại EC2 instance (free tier: t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID cho Amazon Linux 2023 (us-east-1)"
  type        = string
  default     = "ami-0c7217cdff66f2296"   # Amazon Linux 2023 AMI
}

variable "key_name" {
  description = "Tên Key Pair để SSH vào EC2"
  type        = string
  # KHÔNG đặt default — bắt buộc nhập khi chạy
}

# --- S3 ---
variable "s3_bucket_prefix" {
  description = "Tiền tố tên S3 bucket (tên bucket phải unique toàn cầu)"
  type        = string
  default     = "my-terraform-lab"
}

# --- Tag ---
variable "environment" {
  description = "Môi trường (dev/staging/prod)"
  type        = string
  default     = "dev"
}
