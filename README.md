# Terraform을 이용한 AWS S3 및 EC2 정적 웹사이트 호스팅

이 프로젝트는 Terraform을 사용하여 AWS S3와 EC2를 활용한 정적 웹사이트 호스팅 인프라를 구축합니다.

## 프로젝트 배경

처음에는 AWS EC2 인스턴스를 사용하여 웹사이트를 호스팅하려 했습니다. 하지만 정적 웹사이트의 경우, 굳이 EC2와 같은 리눅스 서버를 구매하여 백그라운드에서 서버 메모리를 사용할 필요가 없다는 것을 깨달았습니다.

대신, AWS S3(Simple Storage Service)를 사용하여 정적 웹사이트를 호스팅하기로 결정했습니다. 이 방법의 장점은 다음과 같습니다:

1. 비용 효율적: 사용한 저장 공간과 데이터 전송량에 대해서만 비용을 지불합니다.
2. 서버 관리 불필요: S3는 서버리스 서비스이므로 서버 관리에 대한 부담이 없습니다.
3. 확장성: S3는 자동으로 확장되므로 트래픽 증가에 대비할 필요가 없습니다.
4. 높은 가용성: AWS의 인프라를 활용하여 높은 가용성을 제공합니다.

AI를 활용한 그림일기 생성 기능이 있는 애플리케이션 프로젝트를 진행한 경험이 있습니다. 이 프로젝트에서는 사용자가 AI로 생성된 그림일기 정보를 AWS S3에 저장했고, 저장된 S3 버킷의 엔드포인트를 그림 URL로 사용했습니다. 이전에는 S3를 데이터 백업 용도로만 활용했지만, 이번에는 정적 웹 호스팅 기능을 사용해 보았습니다.

## 프로젝트 목적

이 프로젝트의 목적은 Terraform을 사용하여 AWS S3 기반의 정적 웹사이트 호스팅 인프라를 구축하는 것입니다. 클라이언트 측에서는 빌드 과정을 통해 HTML, CSS, JavaScript 파일이 생성되므로, 이러한 파일들을 저장하고 제공할 수 있는 인프라만 구축하면 됩니다.

## 기술 스택

- <img src="https://img.shields.io/badge/Amazon s3-569A31?style=flat-square&logo=Amazon s3&logoColor=white" /> : 정적 파일 호스팅
- <img src="https://img.shields.io/badge/terraform-844FBA?style=flat-square&logo=terraform&logoColor=white" /> : 인프라 코드 관리

## 구현 단계

1. Terraform 설치 및 AWS 자격 증명 설정
2. S3 버킷 생성을 위한 Terraform 코드 작성
3. S3 버킷에 정적 웹사이트 호스팅 기능 활성화
4. 버킷 정책 설정을 통한 퍼블릭 액세스 허용
5. 정적 웹사이트 파일 업로드
6. 테스트 및 배포

## 주의사항

- S3 버킷 이름은 전역적으로 유일해야 합니다.
- 보안을 위해 필요한 최소한의 권한만 부여하세요.
- 버전 관리를 고려하여 Terraform 상태 파일을 안전하게 관리하세요.

## 설치 및 설정

### 1. Terraform 설치

```bash
$ sudo su -

# wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# apt-get update && apt-get install terraform -y

# terraform -version
```

### 프로젝트 구조

```bash
.
├── image1.jpg
├── index.html
├── main.html
├── main.tf
├── output.tf
├── resource.tf
├── terraform.tfstate
├── terraform.tfstate.backup
└── updated_index.html
```

- `main.tf`: EC2 인스턴스 및 관련 리소스 정의
- `resource.tf`: S3 버킷 및 관련 설정 정의
- `index.html`: 메인 페이지 HTML
- `main.html`: 부가 페이지 HTML

## Terraform 파일 설명

### `resource.tf`

이 파일은 S3 버킷과 관련된 리소스를 정의합니다.

1. **S3 버킷 생성**:
    
    ```bash
    resource "aws_s3_bucket" "bucket1" {
      bucket = "ce35-bucket1" # bucket 이름 
    }
    
    ```
    
    - `ce35-bucket1`이라는 이름의 S3 버킷을 생성합니다.
2. **S3 버킷 공개 액세스 설정**:
    
    ```
    resource "aws_s3_bucket_public_access_block" "bucket1_public_access_block" {
      bucket = aws_s3_bucket.bucket1.id
      block_public_acls       = false
      block_public_policy     = false
      ignore_public_acls      = false
      restrict_public_buckets = false
    }
    
    ```
    
    - 버킷의 공개 액세스 설정을 관리합니다. 모든 설정을 `false`로 하여 공개 액세스를 허용합니다.
3. **index.html 파일 업로드**:
    
    ```
    resource "aws_s3_object" "index" {
      bucket       = aws_s3_bucket.bucket1.id
      key          = "index.html"
      source       = "index.html"
      content_type = "text/html"
    }
    
    ```
    
    - `index.html` 파일을 S3 버킷에 업로드합니다.
4. **S3 버킷 웹사이트 호스팅 설정**:
    
    ```
    resource "aws_s3_bucket_website_configuration" "xweb_bucket_website" {
      bucket = aws_s3_bucket.bucket1.id
      index_document {
        suffix = "index.html"
      }
    }
    
    ```
    
    - S3 버킷을 정적 웹사이트로 구성하고, `index.html`을 기본 문서로 설정합니다.
5. **S3 버킷 정책 설정**:
    
    ```
    resource "aws_s3_bucket_policy" "public_read_access" {
      bucket = aws_s3_bucket.bucket1.id
      policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": "*",
          "Action": [ "s3:GetObject" ],
          "Resource": [
            "arn:aws:s3:::ce35-bucket1",
            "arn:aws:s3:::ce35-bucket1/*"
          ]
        }
      ]
    }
    EOF
    }
    
    ```
    
    - 버킷의 모든 객체에 대한 공개 읽기 액세스를 허용하는 정책을 설정합니다.

### `main.tf`

이 파일은 EC2 인스턴스와 관련된 리소스를 정의합니다.

[ ?? : 사실 여기서 EC2 관련 설정은 안해도되는데 terraform 을 이용한 EC2 인스턴스 생성을 해보고자 ,,,, 현 과정에선, EC2관련 설정은 해주지 않아도된다. ]

1. **AWS 제공자 설정**:
    
    ```
    provider "aws" {
      region = "ap-northeast-2"
    }
    
    ```
    
    - AWS 리전을 서울(ap-northeast-2)로 설정합니다.
2. **EC2 보안 그룹 생성**:
    
    ```
    resource "aws_security_group" "web_sg" {
      name        = "web_sg"
      description = "Allow HTTP traffic"
      ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
      }
      egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
      }
    }
    
    ```
    
    - HTTP 트래픽(포트 80)을 허용하는 보안 그룹을 생성합니다.
3. **EC2 인스턴스 생성**:
    
    ```
    resource "aws_instance" "ec2_example" {
      ami                    = "ami-****"
      instance_type          = "t2.micro"
      key_name               = "ce35-key"
      vpc_security_group_ids = [aws_security_group.web_sg.id]
      tags = {
        Name = "ce35-ec2"
      }
      user_data = <<-EOF
                  #!/bin/bash
                  yum update -y
                  yum install -y httpd
                  systemctl start httpd
                  systemctl enable httpd
                  mkdir -p /var/www/html
                  aws s3 cp s3://ce35-bucket1/index.html /var/www/html/index.html
                  chmod 755 /var/www/html/index.html
                  EOF
    }
    
    ```
    
    - t2.micro 타입의 EC2 인스턴스를 생성합니다.
    - Apache 웹 서버를 설치하고 S3에서 index.html 파일을 다운로드하는 사용자 데이터 스크립트를 포함합니다.
4. **추가 S3 객체 업로드**:
    
    ```
    resource "aws_s3_bucket_object" "main_html" {
      bucket = "ce35-bucket1"
      key    = "main.html"
      source = "/home/username/s3/main.html"
      content_type = "text/html"
    }
    
    resource "aws_s3_bucket_object" "image" {
      bucket = "ce35-bucket1"
      key    = "image1.jpg"
      source = "/home/username/s3/image1.jpg"
    }
    
    ```
    
    - `main.html` 파일과 `image1.jpg` 이미지를 S3 버킷에 업로드합니다.
5. **동적 index.html 생성 및 업로드**:
    
    ```
    resource "local_file" "updated_index" {
      filename = "${path.module}/updated_index.html"
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
        <a href="main.html">Go to Main Page</a>
    </body>
    </html>
    EOF
    }
    
    resource "aws_s3_bucket_object" "updated_index_html" {
      bucket = "ce35-bucket1"
      key    = "index.html"
      source = local_file.updated_index.filename
      content_type = "text/html"
    }
    
    ```
    
    - 동적으로 `index.html` 파일을 생성하고 S3 버킷에 업로드합니다.
6. **EC2 퍼블릭 IP 출력**:
    
    ```
    output "ec2_public_ip" {
      value = aws_instance.ec2_example.public_ip
    }
    
    ```
    
    - 생성된 EC2 인스턴스의 퍼블릭 IP 주소를 출력합니다.

## HTML 파일 설명

1. **index.html**: 기본 랜딩 페이지입니다.
2. **main.html**: 메인 페이지로, 이미지를 포함합니다.

## 실행 방법

1. 프로젝트 디렉토리로 이동합니다.
2. Terraform 초기화:
    
    ```
    terraform init
    
    ```
    
3. 실행 계획 확인:
    
    ```
    terraform plan
    
    ```
    
4. 인프라 생성:
    
    ```
    terraform apply
    
    ```
    
5. 리소스 삭제 (필요시):
    
    ```
    terraform destroy
    
    ```
    

### 결과

![10161](https://github.com/user-attachments/assets/e50637e8-51a3-402b-91a8-94ed740e2b3a)

쨔쟈쟌

s3에 올라간 index.html 입니다. Main Page로 가는 a태그 클릭시 
![10162](https://github.com/user-attachments/assets/445db18d-298a-4cfd-9013-0e5f425b08c8)

s3에 업로드된 image파일을 포함한 main.html 이 나오는 결과를 확인할 수 있습니다. 

## 주의사항

- S3 버킷 이름은 전역적으로 유일해야 하므로 `resource.tf`와 `main.tf`에서 버킷 이름을 적절히 수정해야 합니다.
- EC2 키 페어 이름을 `main.tf`에서 올바르게 설정했는지 확인합니다.
- 로컬 파일 경로 (`/home/username/s3/main.html`, `/home/username/s3/image1.jpg`)를 실제 환경에 맞게 수정합니다.
