resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "main_dist" {
  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Origin 1: S3 (정적 웹사이트)
  origin {
    domain_name              = aws_s3_bucket.guestbook_s3.bucket_regional_domain_name
    origin_id                = "S3Origin"
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
  }

  # Origin 2: ALB (API 서버)
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
  # Default Cache Behavior (S3로 전송)
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

  # Ordered Cache Behavior (API 요청을 ALB로 전송)
  ordered_cache_behavior {
    path_pattern     = "/api/*"
    target_origin_id = "ALBOrigin"

    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"

    # API는 보통 캐싱을 하지 않거나 헤더를 전달해야 함
    forwarded_values {
      query_string = true
      headers      = ["*"] # 모든 헤더를 ALB로 전달 (CORS 해결)
      cookies {
        forward = "all"
      }
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}
