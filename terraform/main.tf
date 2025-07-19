# Cloud Deployment Configuration for Flutter Loyalty Card App

## AWS Deployment Configuration
resource "aws_s3_bucket" "loyalty_card_bucket" {
  bucket = "loyalty-card-app-${random_string.bucket_suffix.result}"
}

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket_website_configuration" "loyalty_card_website" {
  bucket = aws_s3_bucket.loyalty_card_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "loyalty_card_pab" {
  bucket = aws_s3_bucket.loyalty_card_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "loyalty_card_policy" {
  bucket = aws_s3_bucket.loyalty_card_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.loyalty_card_bucket.arn}/*"
      },
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.loyalty_card_pab]
}

resource "aws_cloudfront_distribution" "loyalty_card_distribution" {
  origin {
    domain_name = aws_s3_bucket.loyalty_card_bucket.bucket_regional_domain_name
    origin_id   = "S3-${aws_s3_bucket.loyalty_card_bucket.id}"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3-${aws_s3_bucket.loyalty_card_bucket.id}"
    compress               = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
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

output "cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.loyalty_card_distribution.domain_name
}

output "s3_bucket_name" {
  value = aws_s3_bucket.loyalty_card_bucket.id
}
