# Lab 3 — Đáp án (Dành cho Giảng viên)

> **KHÔNG chia sẻ file này cho sinh viên!**

---

## Tổng quan

Bài lab yêu cầu sinh viên sử dụng Terraform để cấp phát 2 tài nguyên AWS chính: **EC2 instance** và **S3 bucket**, cùng các tài nguyên phụ trợ (Security Group, S3 configurations).

Kết quả mong đợi: `terraform apply` tạo thành công **7 resources**, `terraform output` hiển thị IP công khai và tên bucket.

---

## Đáp án File Cấu hình

### main.tf — Cấu hình Hoàn chỉnh

```hcl
provider "aws" {
  region = var.region
}

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

resource "aws_security_group" "lab_sg" {
  name        = "lab3-terraform-sg"
  description = "Security Group cho Lab 3 - Cho phép SSH + HTTP"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

resource "aws_s3_bucket" "lab_bucket" {
  bucket = "${var.s3_bucket_prefix}-${random_id.bucket_suffix.hex}"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket_versioning" "lab_bucket_versioning" {
  bucket = aws_s3_bucket.lab_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "lab_bucket_encryption" {
  bucket = aws_s3_bucket.lab_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### variables.tf — Biến

```hcl
variable "region" {
  description = "AWS region để triển khai tài nguyên"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "Loại EC2 instance (free tier: t2.micro)"
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID cho Amazon Linux 2023 (us-east-1)"
  type        = string
  default     = "ami-0c7217cdff66f2296"
}

variable "key_name" {
  description = "Tên Key Pair để SSH vào EC2"
  type        = string
}

variable "s3_bucket_prefix" {
  description = "Tiền tố tên S3 bucket"
  type        = string
  default     = "my-terraform-lab"
}

variable "environment" {
  description = "Môi trường (dev/staging/prod)"
  type        = string
  default     = "dev"
}
```

### outputs.tf — Outputs

```hcl
output "ec2_instance_id" {
  description = "ID của EC2 instance vừa tạo"
  value       = aws_instance.lab_server.id
}

output "ec2_public_ip" {
  description = "Địa chỉ IP Public của EC2"
  value       = aws_instance.lab_server.public_ip
}

output "ec2_public_dns" {
  description = "DNS Public của EC2"
  value       = aws_instance.lab_server.public_dns
}

output "ec2_private_ip" {
  description = "Địa chỉ IP Private của EC2"
  value       = aws_instance.lab_server.private_ip
}

output "s3_bucket_name" {
  description = "Tên S3 bucket đã tạo"
  value       = aws_s3_bucket.lab_bucket.bucket
}

output "s3_bucket_arn" {
  description = "ARN của S3 bucket"
  value       = aws_s3_bucket.lab_bucket.arn
}

output "ssh_connect_command" {
  description = "Lệnh SSH để kết nối vào EC2"
  value       = "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.lab_server.public_dns}"
}

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
```

---

## Kết quả Mong đợi

### Sau `terraform apply`:

```
Outputs:

ec2_instance_id = "i-0a1b2c3d4e5f67890"
ec2_public_ip = "54.123.45.67"
ec2_public_dns = "ec2-54-123-45-67.compute-1.amazonaws.com"
ec2_private_ip = "172.31.16.100"
s3_bucket_name = "my-terraform-lab-a1b2c3d4"
s3_bucket_arn = "arn:aws:s3:::my-terraform-lab-a1b2c3d4"
ssh_connect_command = "ssh -i ~/.ssh/my-key.pem ec2-user@ec2-54-123-45-67.compute-1.amazonaws.com"
lab_summary = {
  EC2_ID    = "i-0a1b2c3d4e5f67890"
  EC2_IP    = "54.123.45.67"
  S3_Bucket = "my-terraform-lab-a1b2c3d4"
  ...
}
```

### Resources được tạo (7 resources):

```
aws_instance.lab_server
aws_security_group.lab_sg
aws_s3_bucket.lab_bucket
random_id.bucket_suffix
aws_s3_bucket_versioning.lab_bucket_versioning
aws_s3_bucket_server_side_encryption_configuration.lab_bucket_encryption
```

### Sau `terraform destroy`:

```
Destroy complete! Resources: 7 destroyed.
terraform state list → (rỗng)
```

---

## Các Lỗi Sinh viên Thường Gặp

| # | Lỗi | Nguyên nhân thường gặp | Cách hướng dẫn |
|---|------|----------------------|----------------|
| 1 | Chưa tạo Key Pair trên AWS | Nhiều SV bỏ qua bước này | Nhắc SV vào EC2 → Key Pairs → Create |
| 2 | Quên `vpc_security_group_ids` | Viết EC2 resource xong không gán SG | Chỉ vào dòng thiếu trong main.tf |
| 3 | Dùng AMI ID sai region | Copy AMI ID từ internet không kiểm tra region | Hướng dẫn tra AMI Catalog trên Console |
| 4 | `terraform destroy` xong vẫn bị tính tiền | Có resource tạo thủ công ngoài Terraform | Kiểm tra AWS Console → xóa manual |
| 5 | Commit `terraform.tfstate` lên GitHub | Không có `.gitignore` | Thêm `.gitignore` với `*.tfstate` và `.terraform/` |
| 6 | Không chạy `terraform destroy` sau lab | Quên dọn dẹp | Nhấn mạnh: free tier có giới hạn, vượt qua sẽ bị tính phí |
| 7 | Gõ nhầm `key_name` | Typo khi nhập biến | Yêu cầu copy-paste tên key từ AWS Console |

---

## Câu hỏi Vấn đáp (Dùng khi chấm vấn đáp)

1. **"Terraform state file (`terraform.tfstate`) chứa gì? Tại sao không nên commit nó?"**
   → Chứa mapping giữa resource trong code và resource thật trên AWS (bao gồm cả thông tin nhạy cảm). Không commit vì lộ thông tin và gây conflict khi nhiều người cùng làm.

2. **"Sự khác biệt giữa `terraform plan` và `terraform apply`?"**
   → `plan` chỉ xem trước (dry-run), không thay đổi gì. `apply` thực sự gọi AWS API để tạo tài nguyên.

3. **"Nếu bạn sửa `instance_type` từ `t2.micro` thành `t3.micro` rồi chạy `terraform apply`, điều gì xảy ra?"**
   → EC2 sẽ bị destroy và recreate (vì change in instance type requires replacement), hoặc có thể update in-place tùy loại thay đổi.

4. **"Tại sao dùng `variables.tf` thay vì ghi cứng giá trị trong `main.tf`?"**
   → Tái sử dụng code cho nhiều môi trường (dev/staging/prod), dễ bảo trì, dễ đọc.

5. **"Làm sao để chia sẻ Terraform state giữa các thành viên trong team?"**
   → Dùng remote backend (S3 + DynamoDB lock), hoặc Terraform Cloud.

---

## Tiêu chí Chấm điểm Chi tiết

### Cách chấm từng mục:

| Tiêu chí | Điểm | Cách chấm |
|----------|:----:|-----------|
| Cài đặt & cấu hình OK | 10 | `terraform version` ≥ 1.11 + `aws sts get-caller-identity` trả về thông tin |
| Cấu trúc dự án đúng | 10 | Có main.tf + variables.tf + outputs.tf |
| variables.tf đầy đủ | 10 | Có ít nhất 5 biến với description |
| main.tf: provider + EC2 | 10 | `aws_instance` được khai báo đúng |
| main.tf: Security Group | 5 | SG có rule SSH (port 22) |
| main.tf: S3 + configurations | 10 | S3 + versioning + encryption |
| outputs.tf có IP, DNS, bucket | 10 | `terraform output` hiển thị đủ |
| init → plan đúng | 5 | Plan hiển thị "7 to add" |
| apply thành công | 10 | "Apply complete! Resources: 7 added" |
| Verify trên Console | 10 | Có screenshot EC2 + S3 |
| Destroy sạch | 10 | `terraform state list` rỗng |
| **TỔNG** | **100** | |

### Xếp loại:
- **Giỏi (≥85):** Hoàn thành đủ + có bài tập mở rộng (user_data Apache hoặc VPC riêng)
- **Khá (70-84):** Hoàn thành đủ các bước, apply thành công, destroy sạch
- **TB (50-69):** Apply được nhưng thiếu output hoặc chưa destroy
- **Yếu (<50):** Chưa apply được, thiếu nhiều file
