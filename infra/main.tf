# Data source for current AWS account ID
data "aws_caller_identity" "current" {}

# S3 Bucket for Profile Website
resource "aws_s3_bucket" "profile_bucket" {
  bucket        = var.bucket_name
  force_destroy = true # Allow bucket to be destroyed even if not empty
}

resource "aws_s3_bucket_versioning" "profile_bucket_versioning" {
  bucket = aws_s3_bucket.profile_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block public access - CloudFront will handle distribution
resource "aws_s3_bucket_public_access_block" "profile_bucket_pab" {
  bucket = aws_s3_bucket.profile_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudFront Origin Access Control
resource "aws_cloudfront_origin_access_control" "profile_oac" {
  name                              = "profile-oac"
  description                       = "OAC for profile S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# S3 Bucket Policy for CloudFront
resource "aws_s3_bucket_policy" "profile_bucket_policy" {
  bucket = aws_s3_bucket.profile_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "CloudFrontAccess"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.profile_bucket.arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.profile_distribution.id}"
        }
      }
    }]
  })
}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "profile_distribution" {
  origin {
    domain_name              = aws_s3_bucket.profile_bucket.bucket_regional_domain_name
    origin_id                = "S3ProfileBucket"
    origin_access_control_id = aws_cloudfront_origin_access_control.profile_oac.id
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"
  price_class         = var.price_class

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = "S3ProfileBucket"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      # IMPORTANTE: como o Cognito volta com ?code=...&state=...
      # é melhor permitir query string no request para o CloudFront.
      query_string = true

      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # SPA fallback para rotas (quando S3 responde 403 em bucket privado)
  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  # SPA fallback para 404 também
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = { Name = "todo-list-distribution" }
}
