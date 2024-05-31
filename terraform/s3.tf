resource "aws_s3_bucket" "app-prod-react" {
  bucket = "app-prod-react"

  tags = {
    Name = "app-prod-react"
  }
}

resource "aws_s3_bucket_ownership_controls" "app-prod-react-ownership" {
  bucket = aws_s3_bucket.app-prod-react.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "app-prod-react-acl" {
  depends_on = [aws_s3_bucket_ownership_controls.app-prod-react-ownership]

  bucket = aws_s3_bucket.app-prod-react.id
  acl    = "private"
}

resource "aws_s3_object" "app-prod-react-admin" {
  bucket = aws_s3_bucket.app-prod-react.id
  content_type = "application/x-directory"
  key = "admin/"
}

resource "aws_s3_object" "app-prod-react-user" {
  bucket = aws_s3_bucket.app-prod-react.id
  content_type = "application/x-directory"
  key = "user/"
}