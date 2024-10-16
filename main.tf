provider "aws" {
  region = "ap-northeast-2"
}

# EC2 보안 그룹 생성
resource "aws_security_group" "web_sg" {
  name        = "web_sg"
  description = "Allow HTTP traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 허용
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # 모든 IP 허용
  }
}

# EC2 인스턴스 생성
resource "aws_instance" "ec2_example" {
  ami                    = "ami-00dade17b7cbec931"  # 원하는 AMI ID
  instance_type          = "t2.micro"
  key_name               = "ce35-key"  # 기존 키페어 이름을 직접 참조
  vpc_security_group_ids = [aws_security_group.web_sg.id]  # 보안 그룹 추가

  tags = {
    Name = "ce35-ec2"
  }

  user_data = <<-EOF
              #!/bin/bash
              # Update packages
              yum update -y
              
              # Install Apache web server
              yum install -y httpd
              
              # Start Apache service
              systemctl start httpd
              systemctl enable httpd
              
              # Create a directory for web files
              mkdir -p /var/www/html
              
              # Download the updated_index.html from S3
              aws s3 cp s3://ce35-bucket1/index.html /var/www/html/index.html
              
              # Change permissions for public access
              chmod 755 /var/www/html/index.html
              EOF
}

# S3에 main.html 업로드
resource "aws_s3_bucket_object" "main_html" {
  bucket = "ce35-bucket1"
  key    = "main.html"
  source = "/home/username/s3/main.html"  # 로컬 main.html 파일 경로
  content_type = "text/html"  
}

# S3에 이미지 업로드
resource "aws_s3_bucket_object" "image" {
  bucket = "ce35-bucket1"  # S3 버킷 이름
  key    = "image1.jpg"      # S3에서의 파일 이름
  source = "/home/username/s3/image1.jpg"  # 로컬 이미지 파일 경로
}

# 로컬 updated_index.html을 S3의 index.html로 업로드
resource "local_file" "updated_index" {
  filename = "${path.module}/updated_index.html"  # 수정된 파일을 저장할 경로
  content  = <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<body>
    <h1>ce35 hello</h1>
    <a href="https://ce35-bucket1.s3.ap-northeast-2.amazonaws.com/main.html">Go to Main Page</a>
</body>
</html>
EOF
}

resource "aws_s3_bucket_object" "updated_index_html" {
  bucket = "ce35-bucket1"
  key    = "index.html"  # S3에서 사용할 파일 이름
  source = local_file.updated_index.filename  # 생성한 local_file의 경로 사용
  content_type = "text/html" 
}

# EC2 퍼블릭 IP 출력
output "ec2_public_ip" {
  value = aws_instance.ec2_example.public_ip
}
