output "cloudfront_distribution_id" {
  description = "ID da distribuição CloudFront"
  value       = var.enable_create_resources && length(aws_cloudfront_distribution.frontend) > 0 ? aws_cloudfront_distribution.frontend[0].id : null
}

output "cloudfront_domain_name" {
  description = "Nome de domínio do CloudFront (ex: d1234abcd.cloudfront.net)"
  value       = var.enable_create_resources && length(aws_cloudfront_distribution.frontend) > 0 ? aws_cloudfront_distribution.frontend[0].domain_name : null
}

output "cloudfront_url" {
  description = "URL completa do CloudFront com https://"
  value       = var.enable_create_resources && length(aws_cloudfront_distribution.frontend) > 0 ? "https://${aws_cloudfront_distribution.frontend[0].domain_name}" : null
}

output "cloudfront_arn" {
  description = "ARN da distribuição CloudFront"
  value       = var.enable_create_resources && length(aws_cloudfront_distribution.frontend) > 0 ? aws_cloudfront_distribution.frontend[0].arn : null
}

output "s3_bucket_name" {
  description = "Nome do bucket S3"
  value       = var.s3_bucket_name
}

output "s3_bucket_id" {
  description = "ID do bucket S3"
  value       = var.enable_create_resources && length(aws_s3_bucket.frontend) > 0 ? aws_s3_bucket.frontend[0].id : var.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = var.enable_create_resources && length(aws_s3_bucket.frontend) > 0 ? aws_s3_bucket.frontend[0].arn : "arn:aws:s3:::${var.s3_bucket_name}"
}

output "s3_bucket_domain_name" {
  description = "Nome de domínio do bucket S3"
  value       = var.enable_create_resources && length(aws_s3_bucket.frontend) > 0 ? aws_s3_bucket.frontend[0].bucket_domain_name : "${var.s3_bucket_name}.s3.amazonaws.com"
}

output "oac_id" {
  description = "ID do Origin Access Control (OAC)"
  value       = var.enable_create_resources && length(aws_cloudfront_origin_access_control.frontend) > 0 ? aws_cloudfront_origin_access_control.frontend[0].id : null
}

