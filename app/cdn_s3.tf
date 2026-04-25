resource "aws_s3_bucket" "guestbook_s3" {
  bucket        = "guestbook-tf-j4eu-bucket" # 버킷 이름
  force_destroy = true                       # destroy 할 때 저장된 객체 모두 삭제

  tags = {
    Name = "Guestbook-tf-J4EU-S3"
  }
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.guestbook_s3.id

  # 모든 퍼블릭 액세스를 차단
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 이 리소스를 추가하면 S3가 정적 웹사이트 호스팅 활성화됨 (CloudFront OAC를 사용할 경우 사용 안 함)
# resource "aws_s3_bucket_website_configuration" "guestbook_website" {
#   bucket = aws_s3_bucket.guestbook_s3.id

#   index_document {
#     suffix = "index.html" # 색인
#   }
# }

# index.html 파일을 S3에 업로드
resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.guestbook_s3.id

  key          = "index.html"                # S3 안에서 저장될 파일명
  source       = "${path.module}/index.html" # Terraform 모듈 폴더 기준 로컬 파일을 읽음
  content_type = "text/html"                 # 브라우저가 HTML로 제대로 해석

  etag = filemd5("${path.module}/index.html") # 로컬 파일이 바뀔 때 Terraform이 변경을 감지
}

# CloudFront 원본 액세스 제어
resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-oac"
  origin_access_control_origin_type = "s3"     # S3 원본 액세스 제어
  signing_behavior                  = "always" # 항상 서명
  signing_protocol                  = "sigv4"  # 서명 프로토콜
}

# CloudFront 배포
resource "aws_cloudfront_distribution" "main" {
  enabled             = true         # CloudFront 활성화
  is_ipv6_enabled     = true         # IPv6 활성화
  default_root_object = "index.html" # 기본 루트 객체

  # 원본 1: S3 (정적 웹사이트)
  origin {
    domain_name              = aws_s3_bucket.guestbook_s3.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # 원본 2: ALB (API 서버)
  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = "ALBOrigin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # 기본 캐시 동작 (S3로 전송)
  default_cache_behavior {
    target_origin_id       = "S3Origin"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  # 순서 지정 캐시 동작 (API 요청을 ALB로 전송)
  ordered_cache_behavior {
    path_pattern     = "/api/*" # API 요청 패턴
    target_origin_id = "ALBOrigin"

    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    # API는 보통 캐싱을 하지 않거나 헤더를 전달해야 함
    forwarded_values {
      query_string = true  # 쿼리 문자열 전달
      headers      = ["*"] # 모든 헤더를 ALB로 전달 (CORS 해결)
      cookies {
        forward = "all" # 모든 쿠키를 ALB로 전달
      }
    }
  }

  # 지역 제한
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["KR"]
    }
  }

  # 뷰어 인증서
  viewer_certificate {
    cloudfront_default_certificate = true # 기본 인증서 사용
  }
}

# S3 버킷 정책
resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.guestbook_s3.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.guestbook_s3.arn}/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.main.arn]
    }
  }
}
