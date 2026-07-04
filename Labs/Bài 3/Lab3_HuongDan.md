# Lab 3: Cấp phát Hạ tầng Đám mây với Terraform & AWS

> **Hướng dẫn chi tiết từng bước — Thời lượng: 90 phút**

---

## Mục tiêu

Sau khi hoàn thành lab này, bạn sẽ:

1.  Viết được file cấu hình Terraform (.tf) để khai báo tài nguyên AWS
2.  Sử dụng thành thạo quy trình: `terraform init` → `plan` → `apply` → `destroy`
3.  Cấp phát được **máy chủ ảo EC2** và **S3 bucket** trên AWS chỉ bằng mã
4.  Truy xuất thông tin tài nguyên đã tạo qua Terraform outputs
5.  Dọn dẹp tài nguyên đúng cách, không để phát sinh chi phí

---

## Yêu cầu Hệ thống

| Thành phần | Yêu cầu | Ghi chú |
|------------|---------|---------|
| OS | Windows 10+/macOS/Linux | |
| RAM | ≥ 4GB | |
| Disk | ≥ 2GB trống | |
| Internet | Có | Để kết nối AWS API |
| **Tài khoản AWS** | Free Tier | [Đăng ký tại đây](https://aws.amazon.com/free/) |
| **Terraform** | ≥ 1.11.x | [Tải tại đây](https://developer.hashicorp.com/terraform/downloads) |
| **AWS CLI** | ≥ 2.x | [Tải tại đây](https://aws.amazon.com/cli/) |
| **VS Code** | Bản mới nhất | Hoặc trình soạn thảo code bất kỳ |
| **Git Bash** | (Windows) | Đã có sẵn nếu cài Git |

---

## KIẾN THỨC NỀN — Nhắc lại trước khi làm Lab

### Terraform Workflow (4 bước)

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│   VIẾT   │───▶│   INIT  │───▶│   PLAN   │───▶│  APPLY  │
│  file.tf │    │  tải     │    │  xem     │    │  tạo tài │
│          │    │  plugin  │    │  trước   │    │  nguyên  │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
```

### Cấu trúc File Terraform

```
terraform-aws-lab/           ← Thư mục dự án
├── main.tf                  ← Provider + Resources (code chính)
├── variables.tf             ← Biến (có thể tùy chỉnh)
└── outputs.tf               ← Giá trị xuất ra sau khi tạo
```

### Các Lệnh Terraform Chính

| Lệnh | Chức năng | Khi nào dùng |
|------|-----------|-------------|
| `terraform init` | Khởi tạo + tải plugin | Chạy lần đầu, hoặc khi thêm provider mới |
| `terraform fmt` | Format code đúng chuẩn | Trước khi commit |
| `terraform validate` | Kiểm tra cú pháp | Sau khi viết file .tf |
| `terraform plan` | Xem trước thay đổi | Trước mỗi lần apply |
| `terraform apply` | Thực thi tạo tài nguyên | Sau khi plan OK |
| `terraform destroy` | Xóa toàn bộ tài nguyên | Khi không dùng nữa |

---

## BƯỚC 1: Chuẩn bị Môi trường (15 phút)

### Mục đích
Cài đặt Terraform, AWS CLI và cấu hình thông tin xác thực AWS.

### 1.1 Cài đặt Terraform

#### Windows (dùng Chocolatey — khuyến nghị)
```powershell
# Mở PowerShell với quyền Administrator
choco install terraform
```

#### Windows (cài thủ công)
1. Tải Terraform từ: https://developer.hashicorp.com/terraform/downloads
2. Giải nén file zip → được file `terraform.exe`
3. Copy `terraform.exe` vào `C:\Windows\System32\` hoặc thêm vào PATH

#### macOS
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

#### Linux (Ubuntu/Debian)
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### 1.2 Kiểm tra cài đặt Terraform

```bash
terraform version
```

**Kết quả mong đợi:**
```
Terraform v1.11.x
on windows_amd64    (hoặc darwin_amd64 / linux_amd64)
```

✅ **CHECKPOINT 1:** Terraform đã cài đặt thành công? Gõ `terraform version` thấy version ≥ 1.11.

### 1.3 Cài đặt AWS CLI

#### Windows
```powershell
msiexec.exe /i https://awscli.amazonaws.com/AWSCLIV2.msi
```

#### macOS
```bash
brew install awscli
```

#### Linux
```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 1.4 Cấu hình AWS Credentials

> ⚠️ **QUAN TRỌNG:** KHÔNG dùng tài khoản root! Hãy tạo IAM user với quyền phù hợp.

#### Tạo IAM User trên AWS Console:

1. Đăng nhập AWS Console → IAM → Users → Create user
2. Đặt tên: `terraform-lab-student`
3. Chọn "Attach policies directly":
   - `AmazonEC2FullAccess`
   - `AmazonS3FullAccess`
4. Tạo Access Key (loại: Command Line Interface)
5. **LƯU NGAY** Access Key ID và Secret Access Key (chỉ hiện 1 lần!)

#### Cấu hình AWS CLI:

```bash
aws configure
```

Nhập thông tin khi được hỏi:
```
AWS Access Key ID [None]: AKIAXXXXXXXXXXXXX      ← Key ID của bạn
AWS Secret Access Key [None]: xxxxxxxxxxxxxxx     ← Secret Key của bạn
Default region name [None]: us-east-1              ← Chọn region gần nhất
Default output format [None]: json                 ← Để mặc định json
```

#### Kiểm tra kết nối AWS:

```bash
aws sts get-caller-identity
```

**Kết quả mong đợi:**
```json
{
    "UserId": "AIDAXXXXXXXXXXXXX",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/terraform-lab-student"
}
```

✅ **CHECKPOINT 2:** AWS CLI hoạt động? Chạy lệnh trên và thấy thông tin tài khoản.

>  **BẢO MẬT:** Không bao giờ commit Access Key lên GitHub! Terraform sẽ tự động đọc từ file credentials của AWS CLI.

---

## BƯỚC 2: Tạo Cấu trúc Dự án Terraform (5 phút)

### Mục đích
Tạo thư mục dự án với cấu trúc chuẩn của Terraform.

```bash
# Tạo thư mục dự án
mkdir terraform-aws-lab
cd terraform-aws-lab

# Tạo 3 file Terraform chính
touch main.tf variables.tf outputs.tf
```

Cấu trúc sau khi tạo:
```
terraform-aws-lab/
├── main.tf
├── variables.tf
└── outputs.tf
```

✅ **CHECKPOINT 3:** Đã tạo đủ 3 file .tf trong thư mục `terraform-aws-lab`?

---

## BƯỚC 3: Viết File variables.tf (10 phút)

### Mục đích
Khai báo các biến để cấu hình linh hoạt, không "cứng hóa" giá trị trong code.

Mở `variables.tf` trong VS Code và viết:

```hcl
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
```

### Giải thích
| Biến | Ý nghĩa | Tại sao cần? |
|------|---------|-------------|
| `region` | Region AWS | Có thể đổi region mà không sửa main.tf |
| `instance_type` | Loại máy ảo | Dùng `t2.micro` (free tier) |
| `ami_id` | ID của Amazon Linux image | Mỗi region có AMI ID khác nhau |
| `key_name` | Tên SSH key | **Bắt buộc nhập**, không có default |
| `s3_bucket_prefix` | Tiền tố tên bucket | S3 bucket cần tên duy nhất toàn cầu |
| `environment` | Tag môi trường | Giúp phân loại tài nguyên |

>  **Lưu ý về AMI ID:** AMI ID `ami-0c7217cdff66f2296` là Amazon Linux 2023 ở region `us-east-1`. Nếu bạn chọn region khác, cần tra cứu AMI ID tương ứng trên AWS Console → EC2 → AMI Catalog.

✅ **CHECKPOINT 4:** File `variables.tf` đã viết đúng? Mở file kiểm tra đủ 5 biến.

---

## BƯỚC 4: Viết File main.tf — Trái tim của Lab (20 phút)

### Mục đích
Đây là file chính: khai báo provider AWS và các tài nguyên cần tạo (EC2 + S3).

Mở `main.tf` và viết:

```hcl
# ============================================================
# main.tf — Cấu hình chính: Provider + Resources
# ============================================================

# ----- 1. Cấu hình Provider AWS -----
provider "aws" {
  region = var.region
}

# ----- 2. Tạo EC2 Instance (máy chủ ảo) -----
resource "aws_instance" "lab_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

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

  # Cho phép SSH từ mọi nơi (có giới hạn IP thì tốt hơn)
  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   #  Trong thực tế: giới hạn IP của bạn
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

# ----- 4. Gán Security Group vào EC2 -----
# (điều chỉnh aws_instance để dùng security group này)
# Chúng ta sẽ cập nhật resource EC2 ở trên bằng cách thêm dòng:
# vpc_security_group_ids = [aws_security_group.lab_sg.id]

# ----- 5. Tạo S3 Bucket (lưu trữ) -----
resource "aws_s3_bucket" "lab_bucket" {
  bucket = "${var.s3_bucket_prefix}-${random_id.bucket_suffix.hex}"
  # Tên bucket phải unique toàn cầu → thêm suffix ngẫu nhiên
}

# ----- 6. Random ID để tạo tên bucket unique -----
resource "random_id" "bucket_suffix" {
  byte_length = 4   # 8 ký tự hex
}

# ----- 7. Cấu hình S3 Bucket -----
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

# ----- 8. Tags mặc định cho tất cả resources -----
# (khai báo tags chung để áp dụng cho provider)
```

###  QUAN TRỌNG — Cập nhật EC2 Resource

Quay lại phần `resource "aws_instance" "lab_server"` và **thêm dòng** `vpc_security_group_ids` vào sau dòng `key_name`:

```hcl
resource "aws_instance" "lab_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.lab_sg.id]   # ← THÊM DÒNG NÀY

  tags = {
    Name        = "Lab3-Terraform-Server"
    Environment = var.environment
    ManagedBy   = "Terraform"
    Course      = "DevOps-Bai3"
  }
}
```

### Giải thích từng Resource

| Resource | Loại tài nguyên AWS | Giải thích |
|----------|---------------------|------------|
| `aws_instance` | EC2 — Máy chủ ảo | Server chạy ứng dụng. `t2.micro` = free tier |
| `aws_security_group` | Security Group — Tường lửa | Mở port 22 (SSH) và 80 (HTTP) |
| `aws_s3_bucket` | S3 — Lưu trữ object | Lưu file, backup, static website |
| `random_id` | ID ngẫu nhiên | Tạo suffix cho tên bucket (phải unique toàn cầu) |
| `aws_s3_bucket_versioning` | Versioning cho S3 | Giữ lịch sử thay đổi của file |
| `aws_s3_bucket_server_side_encryption_configuration` | Mã hóa S3 | Bảo mật dữ liệu với AES256 |

>  **Best Practice:** Bật Versioning và Encryption cho S3 bucket là DevOps best practice về bảo mật và an toàn dữ liệu.

✅ **CHECKPOINT 5:** File `main.tf` đã có đủ: provider, EC2, S3, Security Group, random_id? Kiểm tra xong chạy thử:
```bash
terraform fmt      # Format code
terraform validate # Kiểm tra cú pháp
```

---

## BƯỚC 5: Viết File outputs.tf (5 phút)

### Mục đích
Khai báo các giá trị sẽ được hiển thị sau khi `terraform apply` thành công (như IP public, tên bucket...).

Mở `outputs.tf` và viết:

```hcl
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
```

✅ **CHECKPOINT 6:** File `outputs.tf` có đủ 6 output blocks? Chạy `terraform validate` để kiểm tra.

---

## BƯỚC 6: Triển khai — init → plan → apply (20 phút)

### Mục đích
Thực thi quy trình Terraform để tạo tài nguyên thật trên AWS.

### 6.1 Khởi tạo: `terraform init`

```bash
# Đứng trong thư mục terraform-aws-lab/
terraform init
```

**Kết quả mong đợi:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Finding hashicorp/random versions matching "~> 3.0"...
- Installing hashicorp/aws v5.XX.X...
- Installing hashicorp/random v3.X.X...
Terraform has been successfully initialized!
```

>  `terraform init` tải 2 provider plugins: **AWS** (để làm việc với AWS API) và **Random** (để tạo ID ngẫu nhiên).

### 6.2 Format & Kiểm tra cú pháp

```bash
terraform fmt -recursive   # Format code đẹp
terraform validate         # Kiểm tra lỗi cú pháp
```

**Kết quả mong đợi:**
```
Success! The configuration is valid.
```

### 6.3 Xem trước thay đổi: `terraform plan`

```bash
terraform plan
```

Terraform sẽ hỏi bạn nhập giá trị cho biến `key_name` (vì biến này không có default):

```
var.key_name
  Tên Key Pair để SSH vào EC2

  Enter a value: my-aws-key     ← Nhập tên Key Pair của bạn
```

**Kết quả mong đợi:** Terraform hiển thị danh sách tài nguyên SẼ được tạo:
```
Terraform will perform the following actions:

  # aws_instance.lab_server will be created
  + resource "aws_instance" "lab_server" {
      + ami                          = "ami-0c7217cdff66f2296"
      + instance_type                = "t2.micro"
      + key_name                     = "my-aws-key"
      ...
    }

  # aws_security_group.lab_sg will be created
  + resource "aws_security_group" "lab_sg" {
      ...
    }

  # aws_s3_bucket.lab_bucket will be created
  + resource "aws_s3_bucket" "lab_bucket" {
      + bucket = "my-terraform-lab-a1b2c3d4"
      ...
    }

Plan: 7 to add, 0 to change, 0 to destroy.
```

>  **Đọc kỹ output của `terraform plan`!** Dấu `+` màu xanh = tài nguyên sẽ được tạo mới. Dấu `-` màu đỏ = tài nguyên sẽ bị xóa. Dấu `~` màu vàng = tài nguyên sẽ bị thay đổi.

### 6.4 Thực thi: `terraform apply`

```bash
terraform apply
```

Terraform hiển thị lại plan và yêu cầu xác nhận:
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes     ← Gõ "yes" để xác nhận
```

**Kết quả mong đợi:**
```
aws_s3_bucket.lab_bucket: Creating...
aws_security_group.lab_sg: Creating...
aws_instance.lab_server: Creating...
...
aws_instance.lab_server: Still creating... [10s elapsed]
...
aws_instance.lab_server: Creation complete after 45s

Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

Outputs:

ec2_instance_id = "i-0a1b2c3d4e5f67890"
ec2_public_ip = "54.123.45.67"
ec2_public_dns = "ec2-54-123-45-67.compute-1.amazonaws.com"
ec2_private_ip = "172.31.16.100"
s3_bucket_name = "my-terraform-lab-a1b2c3d4"
s3_bucket_arn = "arn:aws:s3:::my-terraform-lab-a1b2c3d4"
ssh_connect_command = "ssh -i ~/.ssh/my-aws-key.pem ec2-user@ec2-54-123-45-67.compute-1.amazonaws.com"
```

 **CHÚC MỪNG!** Bạn vừa cấp phát hạ tầng AWS bằng code thành công!

✅ **CHECKPOINT 7:** `terraform apply` thành công? Màn hình hiển thị "Apply complete! Resources: 7 added..."

---

## BƯỚC 7: Kiểm tra Kết quả & Dọn dẹp (15 phút)

### 7.1 Kiểm tra trên AWS Console

#### Kiểm tra EC2:
1. Vào AWS Console → EC2 → Instances
2. Tìm instance `Lab3-Terraform-Server`
3. Kiểm tra: Instance state = **Running**, Public IPv4 = khớp với output

#### Kiểm tra S3:
1. Vào AWS Console → S3 → Buckets
2. Tìm bucket có tên bắt đầu bằng `my-terraform-lab-`
3. Kiểm tra: Versioning = **Enabled**, Encryption = **AES256**

### 7.2 Kiểm tra bằng AWS CLI

```bash
# Kiểm tra EC2
aws ec2 describe-instances --filters "Name=tag:Name,Values=Lab3-Terraform-Server" --query "Reservations[*].Instances[*].[InstanceId,State.Name,PublicIpAddress]" --output table

# Kiểm tra S3
aws s3 ls | grep my-terraform-lab
```

### 7.3 Xem lại Outputs

```bash
terraform output
```

Hiển thị tất cả outputs đã khai báo. Để lấy 1 giá trị cụ thể:
```bash
terraform output ec2_public_ip
```

### 7.4 Kiểm tra State File

```bash
# Xem state hiện tại (dạng JSON)
terraform show

# Liệt kê tất cả resources đang được Terraform quản lý
terraform state list
```

**Kết quả mong đợi:**
```
aws_instance.lab_server
aws_s3_bucket.lab_bucket
aws_s3_bucket_server_side_encryption_configuration.lab_bucket_encryption
aws_s3_bucket_versioning.lab_bucket_versioning
aws_security_group.lab_sg
random_id.bucket_suffix
```

>  **Terraform State:** File `terraform.tfstate` lưu trạng thái thực tế của hạ tầng. Đây là file quan trọng nhất — **không xóa, không sửa tay, không commit lên GitHub** (chứa thông tin nhạy cảm)!

### 7.5 Dọn dẹp: `terraform destroy`

>  **RẤT QUAN TRỌNG:** Luôn chạy `terraform destroy` sau khi hoàn thành lab để tránh bị AWS tính phí!

```bash
terraform destroy
```

Terraform hiển thị danh sách tài nguyên sẽ bị xóa và yêu cầu xác nhận:
```
Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes     ← Gõ "yes" để xác nhận
```

**Kết quả mong đợi:**
```
aws_instance.lab_server: Destroying... [id=i-0a1b2c3d4e5f67890]
aws_s3_bucket.lab_bucket: Destroying... [id=my-terraform-lab-a1b2c3d4]
...
Destroy complete! Resources: 7 destroyed.
```

### 7.6 Xác nhận đã dọn dẹp sạch

```bash
# Kiểm tra: không còn resource nào
terraform state list
# (Kết quả: rỗng — không còn gì)

# Kiểm tra AWS: không còn EC2 instance nào
aws ec2 describe-instances --filters "Name=tag:Name,Values=Lab3-Terraform-Server" --query "Reservations[*].Instances[*].[InstanceId,State.Name]"
# (Kết quả: [] — rỗng)
```

✅ **CHECKPOINT 8:** `terraform destroy` thành công? `terraform state list` trả về rỗng?

---

## TROUBLESHOOTING — Xử lý Sự cố Thường gặp

| # | Lỗi | Nguyên nhân | Cách khắc phục |
|---|-----|-------------|----------------|
| 1 | `Error: No valid credential sources found` | Chưa cấu hình AWS credentials | Chạy `aws configure` và nhập Access Key |
| 2 | `Error: InvalidAMIID.NotFound` | AMI ID không tồn tại ở region đã chọn | Tra cứu AMI ID đúng cho region: AWS Console → EC2 → AMI Catalog → "Amazon Linux 2023" |
| 3 | `Error: InvalidKeyPair.NotFound` | Key Pair không tồn tại | Tạo Key Pair trong AWS Console (EC2 → Key Pairs) hoặc kiểm tra tên đã nhập đúng chưa |
| 4 | `Error: BucketAlreadyExists` | Tên S3 bucket đã bị dùng | Đổi `s3_bucket_prefix` trong `variables.tf` thành tên khác |
| 5 | `Error: UnauthorizedOperation` | IAM user không đủ quyền | Gán thêm policies: `AmazonEC2FullAccess`, `AmazonS3FullAccess` |
| 6 | `Error: InvalidInstanceType` | `t2.micro` không khả dụng ở region đó | Đổi sang `t3.micro` hoặc chọn region khác (us-east-1 luôn hỗ trợ t2.micro) |
| 7 | `Error: Error acquiring the state lock` | Terraform khác đang chạy hoặc lock cũ chưa release | Dùng `terraform force-unlock <LOCK_ID>` (tìm LOCK ID trong thông báo lỗi) |
| 8 | `terraform validate` báo lỗi syntax | Code sai cú pháp HCL | Chạy `terraform fmt` để format lại, kiểm tra thiếu dấu `"` hoặc `{}` |

---

## BÀI TẬP MỞ RỘNG (Optional — Cho sinh viên hoàn thành sớm)

### 🟢 Mức Cơ bản
1. **Thay đổi region:** Sửa `var.region` thành `ap-southeast-1` (Singapore), tìm AMI ID tương ứng, chạy lại từ `terraform plan`

### 🟡 Mức Trung bình  
2. **Thêm HTTP Server:** Thêm `user_data` vào EC2 resource để tự động cài Apache web server khi EC2 khởi động:
```hcl
user_data = <<-EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd
  systemctl start httpd
  systemctl enable httpd
  echo "<h1>DevOps Lab 3 - Terraform + AWS</h1>" > /var/www/html/index.html
EOF
```
Sau đó truy cập `http://<ec2_public_ip>` để thấy trang web!

### 🔴 Mức Nâng cao
3. **Tạo VPC riêng:** Tạo VPC + Subnet + Internet Gateway bằng Terraform, rồi triển khai EC2 vào VPC đó thay vì dùng default VPC

---

## TIÊU CHÍ CHẤM ĐIỂM (Rubric)

| # | Tiêu chí | Điểm tối đa | Cách đánh giá |
|---|----------|:----------:|--------------|
| 1 | **Cài đặt & Cấu hình** — Terraform + AWS CLI hoạt động | 10% | `terraform version` + `aws sts get-caller-identity` OK |
| 2 | **Cấu trúc dự án** — Đủ 3 file .tf, cấu trúc đúng chuẩn | 10% | Có main.tf, variables.tf, outputs.tf |
| 3 | **File variables.tf** — Khai báo đầy đủ biến, có description | 10% | Có region, instance_type, ami_id, key_name, env |
| 4 | **File main.tf** — Provider + EC2 + S3 + Security Group | 25% | 7 resources được tạo đúng |
| 5 | **File outputs.tf** — Output IP, DNS, bucket name | 10% | `terraform output` hiển thị đủ thông tin |
| 6 | **Quy trình Terraform** — init → plan → apply đúng thứ tự | 15% | Apply thành công, resources được tạo |
| 7 | **Kiểm tra kết quả** — Verify trên AWS Console | 10% | Chụp màn hình EC2 + S3 trên Console |
| 8 | **Dọn dẹp** — `terraform destroy` sạch, không để rác | 10% | `terraform state list` trả về rỗng |
| **TỔNG** | | **100%** | |

### Cách Nộp bài

Chuẩn bị 1 file ZIP gồm:
```
Lab3_HoTen_MSSV.zip
├── terraform-aws-lab/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── screenshots/
│   ├── 01-terraform-version.png     ← Kết quả terraform version
│   ├── 02-terraform-init.png        ← Kết quả terraform init
│   ├── 03-terraform-plan.png        ← Kết quả terraform plan
│   ├── 04-terraform-apply.png       ← Kết quả terraform apply
│   ├── 05-aws-ec2-console.png       ← EC2 instance trên AWS Console
│   ├── 06-aws-s3-console.png        ← S3 bucket trên AWS Console
│   ├── 07-terraform-output.png      ← Kết quả terraform output
│   └── 08-terraform-destroy.png     ← Kết quả terraform destroy
└── ho_ten_mssv.txt                  ← Họ tên + MSSV
```

Upload lên LMS trước deadline.

---

## Tài liệu Tham khảo

- [Terraform Documentation](https://developer.hashicorp.com/terraform/docs)
- [AWS Provider for Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Free Tier](https://aws.amazon.com/free/)
- [Terraform Best Practices](https://developer.hashicorp.com/terraform/tutorials)
- [HCL (HashiCorp Configuration Language) Guide](https://developer.hashicorp.com/terraform/language)

---

> 🎯 **Lab này tương ứng với:** CDR 3.2 — Vận dụng IaC trong thiết lập và quản lý cấu hình hạ tầng (Mức Bloom: Vận dụng)
>
> 📅 **Cập nhật:** 2026-07-03 | **Đã test với:** Terraform 1.11.x + AWS Provider 5.x
