locals {
  create   = var.enable_create_resources
  has_cert = trimspace(var.certificate_arn) != ""
  aliases  = trimspace(var.domain_name) != "" ? [trimspace(var.domain_name)] : []
}


# -----------------------
# S3 (privado)
# -----------------------
resource "aws_s3_bucket" "frontend" {
  count  = local.create ? 1 : 0
  bucket = var.s3_bucket_name

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  count  = local.create ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "frontend" {
  count  = local.create ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  count  = local.create ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# -----------------------
# CloudFront OAC
# -----------------------
resource "aws_cloudfront_origin_access_control" "frontend" {
  count                             = local.create ? 1 : 0
  name                              = "${var.project_name}-frontend-oac-${var.environment}"
  description                       = "OAC for ${var.project_name} frontend"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# -----------------------
# CloudFront Distribution
# -----------------------
resource "aws_cloudfront_distribution" "frontend" {
  count   = local.create ? 1 : 0
  enabled = true
  comment = "${var.project_name} frontend distribution"

  origin {
    domain_name              = aws_s3_bucket.frontend[0].bucket_regional_domain_name
    origin_id                = "s3-frontend"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend[0].id
  }

  default_root_object = "index.html"
  aliases             = local.aliases
  price_class         = var.price_class

  # SPA fallback (rotas)
  custom_error_response {
    error_code            = 404
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  #custom_error_response {
  #  error_code            = 403
  #  response_code         = 200
  #  response_page_path    = "/index.html"
  #  error_caching_min_ttl = 0
  #}

  default_cache_behavior {
    target_origin_id       = "s3-frontend"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true

    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id          = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"
  }

  viewer_certificate {
    cloudfront_default_certificate = local.has_cert ? false : true
    acm_certificate_arn            = local.has_cert ? var.certificate_arn : null
    ssl_support_method             = local.has_cert ? "sni-only" : null
    minimum_protocol_version       = local.has_cert ? "TLSv1.2_2021" : null
  }

  restrictions {
    dynamic "geo_restriction" {
      for_each = [1]
      content {
        restriction_type = "none"
        # NÃO declare locations aqui (nem vazio)
      }
    }
  }

  tags = {
    Name        = "${var.project_name}-frontend-distribution"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [
    aws_s3_bucket_public_access_block.frontend
  ]
}

resource "aws_cloudfront_cache_policy" "frontend" {
  count       = local.create ? 1 : 0
  name        = "${var.project_name}-frontend-cache-policy-${var.environment}"
  default_ttl = 86400
  max_ttl     = 31536000
  min_ttl     = 0

  parameters_in_cache_key_and_forwarded_to_origin {
    enable_accept_encoding_gzip   = true
    enable_accept_encoding_brotli = true

    cookies_config { cookie_behavior = "none" }
    headers_config { header_behavior = "none" }
    query_strings_config { query_string_behavior = "none" }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_cloudfront_origin_request_policy" "frontend" {
  count   = local.create ? 1 : 0
  name    = "${var.project_name}-frontend-origin-request-policy-${var.environment}"

  cookies_config { cookie_behavior = "none" }
  headers_config { header_behavior = "none" }
  query_strings_config { query_string_behavior = "none" }

  lifecycle {
    prevent_destroy = true
  }
}


# -----------------------
# Bucket policy (OAC -> S3 GetObject)
# -----------------------
resource "aws_s3_bucket_policy" "frontend" {
  count  = local.create ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid    = "AllowCloudFrontServicePrincipal"
      Effect = "Allow"
      Principal = {
        Service = "cloudfront.amazonaws.com"
      }
      Action   = "s3:GetObject"
      Resource = "${aws_s3_bucket.frontend[0].arn}/*"
      Condition = {
        StringEquals = {
          "AWS:SourceArn" = aws_cloudfront_distribution.frontend[0].arn
        }
      }
    }]
  })
}
