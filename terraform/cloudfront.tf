locals {
  s3_origin_id = "myS3Origin"
}

resource "aws_cloudfront_origin_access_control" "admin-front" {
  name                              = "admin-front"
  description                       = "admin front"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_origin_access_control" "user-front" {
  name                              = "user-front"
  description                       = "user front"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "admin-distribution" {
  origin {
    domain_name = aws_s3_bucket.app-prod-react.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.app-prod-react.id
    origin_access_control_id = aws_cloudfront_origin_access_control.admin-front.id
    origin_path = "/admin"
  }

  origin {
    domain_name = aws_lb.app-alb.dns_name
    origin_id   = aws_lb.app-alb.id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  enabled = true
  default_root_object = "index.html"
  comment = "admin distribution"

  aliases = ["app-admin.keencho.com"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.app-prod-react.id

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  ordered_cache_behavior {
    path_pattern = "/api/*"
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id       = aws_lb.app-alb.id

    viewer_protocol_policy = "redirect-to-https"
    default_ttl = 0
    max_ttl     = 0
    min_ttl     = 0

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["KR"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.ssl-certificate-virginia.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code = 403
    error_caching_min_ttl = 10
    response_page_path = "/index.html"
    response_code = 200
  }
}

resource "aws_cloudfront_distribution" "user-distribution" {
  origin {
    domain_name = aws_s3_bucket.app-prod-react.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.app-prod-react.id
    origin_access_control_id = aws_cloudfront_origin_access_control.user-front.id
    origin_path = "/user"
  }


  origin {
    domain_name = aws_lb.app-alb.dns_name
    origin_id   = aws_lb.app-alb.id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_protocol_policy   = "https-only"
      origin_ssl_protocols     = ["TLSv1.2"]
      origin_keepalive_timeout = 5
      origin_read_timeout      = 30
    }
  }

  enabled = true
  default_root_object = "index.html"
  comment = "user distribution"

  aliases = ["app-user.keencho.com"]

  default_cache_behavior {
    allowed_methods        = ["GET", "POST", "PUT", "OPTIONS", "DELETE", "PATCH", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.app-prod-react.id

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 3600
    max_ttl = 86400
  }

  ordered_cache_behavior {
    path_pattern = "/api/*"
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods = ["GET", "HEAD"]
    target_origin_id       = aws_lb.app-alb.id

    viewer_protocol_policy = "redirect-to-https"
    default_ttl = 0
    max_ttl     = 0
    min_ttl     = 0

    forwarded_values {
      query_string = true
      headers      = ["*"]
      cookies {
        forward = "all"
      }
    }
  }

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["KR"]
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.ssl-certificate-virginia.arn
    ssl_support_method = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  custom_error_response {
    error_code = 403
    error_caching_min_ttl = 10
    response_page_path = "/index.html"
    response_code = 200
  }
}