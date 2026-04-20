# AWS-Cloud-Native-Guestbook-Infra

## 파일 트리 구조
```
Step3-Project
├── app
│   ├── alb_sg.tf
│   ├── alb.tf
│   ├── cloudfront.tf
│   ├── data.tf
│   ├── index.html
│   ├── nat_instance_a.tf
│   ├── nat_instance_c.tf
│   ├── nat_sg.tf
│   ├── network_rules.tf
│   ├── provider.tf
│   ├── s3.tf
│   ├── variables.tf
│   ├── was_a.tf
│   ├── was_c.tf
│   └── was_sg.tf
├── database
│   ├── data.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── rds_sg.tf
│   ├── rds.tf
│   └── variables.tf
├── network
│   ├── gateway.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── route.tf
│   ├── subnet.tf
│   └── vpc.tf
└── README.md
```