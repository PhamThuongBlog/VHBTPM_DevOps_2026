# ============================================================
# outputs.tf — Giá trị xuất ra sau khi triển khai
# ============================================================

# --- EC2 Outputs ---
output "ec2_instance_id" {
  description = "ID của EC2 instance vừa tạo"
  value       = aws_instance.lab_server.id
}

output "ec2_public_ip" {
  description = "Địa chỉ IP Public của EC2 (dùng để SSH)"
  value       = aws_instance.lab_server.public_ip
}

output "ec2_public_dns" {
  description = "DNS Public của EC2"
  value       = aws_instance.lab_server.public_dns
}

output "ec2_private_ip" {
  description = "Địa chỉ IP Private của EC2 (trong VPC)"
  value       = aws_instance.lab_server.private_ip
}

# --- S3 Outputs ---
output "s3_bucket_name" {
  description = "Tên S3 bucket đã tạo"
  value       = aws_s3_bucket.lab_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN của S3 bucket"
  value       = aws_s3_bucket.lab_bucket.arn
}

# --- SSH Command (tiện lợi) ---
output "ssh_connect_command" {
  description = "Lệnh SSH để kết nối vào EC2"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.lab_server.public_dns}"
}

# --- Thông tin tổng quan ---
output "lab_summary" {
  description = "Tóm tắt tài nguyên đã tạo"
  value = {
    EC2_ID      = aws_instance.lab_server.id
    EC2_IP      = aws_instance.lab_server.public_ip
    S3_Bucket   = aws_s3_bucket.lab_bucket.bucket
    Environment = var.environment
    Region      = var.region
  }
}
