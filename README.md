# AWS-Cloud-Native-Guestbook-Infra

## 1. 프로젝트 개요

Terraform을 활용하여 AWS 상에 고가용성 방명록 서비스를 구축한 **클라우드 네이티브** 인프라 프로젝트

### 1-1. 프로젝트 목표

1. CloudFront를 통한 `S3` 정적 웹페이지 접근, `ALB`를 통해 API 요청, 데이터를 RDS에 저장
2. `ALB`, `ASG`, `Database subnet group`을 활용한 고가용성 **멀티 AZ** 설계
3. 생명 주기를 기반으로 레이어 분리

## 2. 아키텍처 다이어그램

[![bangmyeonglog-web-seobiseu-akitegcheo-drawio.png](https://i.postimg.cc/fbrJzv0H/bangmyeonglog-web-seobiseu-akitegcheo-drawio.png)](https://postimg.cc/zLTJpK7W)

## 3. 파일 트리 구조

```
.
├── app
│   ├── alb.tf # ALB
│   ├── cdn_s3.tf # CloudFront + S3
│   ├── data.tf
│   ├── index.html
│   ├── nat.tf # NAT 인스턴스
│   ├── network_rules.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── was.tf # WAS + ASG
├── database
│   ├── data.tf
│   ├── main.tf # RDS
│   ├── outputs.tf
│   ├── provider.tf
│   └── variables.tf
├── network
│   ├── main.tf # VPC, 서브넷, IGW 등
│   ├── outputs.tf
│   ├── provider.tf
└── README.md
```

## 4. 기술 스택

- **IaC:** Terraform v1.14.8 (provider: v6.41.0)
- **Cloud:** AWS
- **OS**: Amazon Linux 2023 (ARM64)
- **DB**: MariaDB 11.8

## 5. 주요 기능 및 특징

- **고가용성:** 2개의 AZ(ap-northeast-2a, 2c)를 활용
- **트래픽 라우팅:** CloudFront를 통해 정적 파일(S3)와 API 요청(ALB)을 분리하여 처리
- **Auto Scaling:** CPU 부하에 따른 인스턴스 자동 확장 설정

## 6. 실행 방법

> 본 프로젝트는 레이어별로 분리되어 있어 순차적인 실행이 필요함

```bash
# 실행 순서(network -> database -> app)

# 1. Network 레이어 (VPC, 서브넷, IGW, 라우팅 테이블 등...)
cd network && terraform init && terraform plan
terraform apply

# 2. Database 레이어 (RDS 보안 그룹, RDS 인스턴스)
cd ../database && terraform init && terraform plan
terraform apply

# 3. App 레이어 (CloudFront, S3, NAT Instance, ALB, ASG)
cd ../app && terraform init && terraform plan
terraform apply
```

## 7. 향후 개선 및 보완 사항

본 프로젝트는 학습용 Sandbox로서 다음과 같은 개선이 필요함

### 7-1. 보안 고도화

- **SSM Session Manager 도입**
  - 인바운드 규칙 중, 22번 포트(SSH)를 제거하고 `IAM` 기반의 보안 접속 환경 구축 필요
- **Secret Management**
  - 민감 정보 (RDS PW 등)를 코드에서 분리하여 `AWS Secret Manager` 연동 필요
- **Remote Backend**
  - 협업 및 상태 관리를 위해 `S3`와 `DynamoDB`를 활용한 원격 백엔드 구성 필요
- **HTTPS 전환 및 통신 암호화**
  - SSL/TLS를 발급받아 ALB에 적용 필요
- **AWS WAF 도입**
- **ALB 커스텀 헤더 기반 접근 제한**
  - (CloudFront를 거치지 않는) ALB DNS 접근 제한 필요

### 7-2. 아키텍처 최적화

- **Nat Gateway 전환**
  - 운영 안정성을 위해 NAT Instance를 AWS 관리형 `NAT Gateway`로 대체 필요
  - 정확한 비용 계산 필요
- **IaC 모듈화**
  - 중복되는 리소스(VPC, Subnet 등)를 Terraform Module로 추상화하여 재사용성 향상 필요
