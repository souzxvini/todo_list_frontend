# Local para controlar criação de recursos
locals {
  should_create_resources = var.enable_create_resources
  use_custom_certificate  = var.certificate_arn != ""
  
  # Configuração do viewer_certificate
  viewer_certificate_config = local.use_custom_certificate ? {
    acm_certificate_arn      = var.certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  } : {
    cloudfront_default_certificate = true
  }
}

# S3 Bucket para hospedar arquivos estáticos
resource "aws_s3_bucket" "frontend" {
  count  = local.should_create_resources ? 1 : 0
  bucket = var.s3_bucket_name

  tags = {
    Name        = "${var.project_name}-frontend"
    Environment = var.environment
    Project     = var.project_name
  }
}

# S3 Bucket Versioning
resource "aws_s3_bucket_versioning" "frontend" {
  count  = local.should_create_resources ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# S3 Bucket Server-Side Encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
  count  = local.should_create_resources ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 Bucket Public Access Block
resource "aws_s3_bucket_public_access_block" "frontend" {
  count  = local.should_create_resources ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Origin Access Control (OAC) para CloudFront acessar o bucket S3
resource "aws_cloudfront_origin_access_control" "frontend" {
  count                             = local.should_create_resources ? 1 : 0
  name                              = "${var.project_name}-frontend-oac-${var.environment}"
  description                       = "OAC para ${var.project_name} frontend bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# Data source para obter account ID atual
data "aws_caller_identity" "current" {}

# CloudFront Distribution
resource "aws_cloudfront_distribution" "frontend" {
  count   = local.should_create_resources ? 1 : 0
  comment = "${var.project_name} frontend distribution"
  enabled = true

  origin {
    domain_name              = aws_s3_bucket.frontend[0].bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.frontend[0].id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.frontend[0].id
  }

  default_root_object = "index.html"

  # SPA Routing: redirecionar 404 e 403 para index.html
  custom_error_response {
    error_code         = 404
    response_code      = 200
    response_page_path = "/index.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 200
    response_page_path = "/index.html"
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.frontend[0].id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    compress               = true
  }

  # Configuração de domínio customizado (opcional)
  aliases = var.domain_name != "" ? [var.domain_name] : []

  # Viewer certificate - default ou customizado
  # Usa certificado customizado se certificate_arn for fornecido, senão usa default do CloudFront
  viewer_certificate {
    cloudfront_default_certificate = !local.use_custom_certificate
    acm_certificate_arn            = local.use_custom_certificate ? var.certificate_arn : null
    ssl_support_method             = local.use_custom_certificate ? "sni-only" : null
    minimum_protocol_version       = local.use_custom_certificate ? "TLSv1.2_2021" : null
  }

  restrictions {
    geo_restriction {
      restriction_type = var.price_class == "PriceClass_All" ? "none" : "whitelist"
      locations        = var.price_class == "PriceClass_100" ? ["US", "CA", "GB", "DE"] : (
        var.price_class == "PriceClass_200" ? ["US", "CA", "GB", "DE", "FR", "IT", "ES", "NL", "BE", "AT", "SE", "DK", "NO", "FI", "IE", "PT", "PL"] : []
      )
    }
  }

  price_class = var.price_class

  tags = {
    Name        = "${var.project_name}-frontend-distribution"
    Environment = var.environment
    Project     = var.project_name
  }

  depends_on = [
    aws_s3_bucket.frontend,
    aws_cloudfront_origin_access_control.frontend,
    aws_s3_bucket_public_access_block.frontend
  ]
}

# Bucket Policy para permitir acesso apenas via CloudFront OAC
resource "aws_s3_bucket_policy" "frontend" {
  count  = local.should_create_resources ? 1 : 0
  bucket = aws_s3_bucket.frontend[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
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
      }
    ]
  })

  depends_on = [
    aws_cloudfront_distribution.frontend
  ]
}

