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

resource "aws_s3_bucket_policy" "allow-from-cloudfront-policy" {
  bucket = aws_s3_bucket.app-prod-react.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AllowCloudFrontServicePrincipal",
        Action   = "s3:GetObject",
        Effect   = "Allow",
        Resource = "${aws_s3_bucket.app-prod-react.arn}/*",
        Principal = {
          "Service": "cloudfront.amazonaws.com"
        },
        Condition = {
          StringEquals = {
            "AWS:SourceArn": [
              aws_cloudfront_distribution.admin-distribution.arn,
              aws_cloudfront_distribution.user-distribution.arn,
            ]
          }
        }
      }
    ]
  })
}