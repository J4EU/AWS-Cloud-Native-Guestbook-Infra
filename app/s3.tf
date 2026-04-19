resource "aws_s3_bucket" "guestbook_s3" {
  bucket        = "guestbook-tf-j4eu-bucket" # 버킷 이름
  force_destroy = true                       # destroy 할 때 저장된 객체 모두 삭제

  tags = {
    Name = "Guestbook-tf-J4EU-S3"
  }
}

# 이 리소스를 추가하면 S3가 정적 웹사이트 호스팅 활성화됨 (CloudFront OAC를 사용할 경우 사용 안 함)
# resource "aws_s3_bucket_website_configuration" "guestbook_website" {
#   bucket = aws_s3_bucket.guestbook_s3.id

#   index_document {
#     suffix = "index.html" # 색인
#   }
# }

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.guestbook_s3.id

  key          = "index.html"                # S3 안에서 저장될 파일명
  source       = "${path.module}/index.html" # Terraform 모듈 폴더 기준 로컬 파일을 읽음
  content_type = "text/html"                 # 브라우저가 HTML로 제대로 해석

  etag = filemd5("${path.module}/index.html") # 로컬 파일이 바뀔 때 Terraform이 변경을 감지
}

resource "aws_s3_bucket_public_access_block" "block_public" {
  bucket = aws_s3_bucket.guestbook_s3.id

  # 모든 퍼블릭 액세스를 차단
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "allow_access_from_cloudfront" {
  bucket = aws_s3_bucket.guestbook_s3.id
  policy = data.aws_iam_policy_document.s3_policy.json
}
