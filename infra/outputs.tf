output "cloudfront_distribution_id" {
  description = "ID da distribuição CloudFront"
  value       = aws_cloudfront_distribution.profile_distribution.id
}

output "cloudfront_domain_name" {
  description = "Nome de domínio do CloudFront (ex: d1234abcd.cloudfront.net)"
  value       = aws_cloudfront_distribution.profile_distribution.domain_name
}

output "cloudfront_url" {
  description = "URL completa do CloudFront com https://"
  value       = "https://${aws_cloudfront_distribution.profile_distribution.domain_name}"
}

output "cloudfront_arn" {
  description = "ARN da distribuição CloudFront"
  value       = aws_cloudfront_distribution.profile_distribution.arn
}

output "s3_bucket_name" {
  description = "Nome do bucket S3"
  value       = aws_s3_bucket.profile_bucket.id
}

output "s3_bucket_id" {
  description = "ID do bucket S3"
  value       = aws_s3_bucket.profile_bucket.id
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = aws_s3_bucket.profile_bucket.arn
}

output "s3_bucket_domain_name" {
  description = "Nome de domínio do bucket S3"
  value       = aws_s3_bucket.profile_bucket.bucket_domain_name
}

output "oac_id" {
  description = "ID do Origin Access Control (OAC)"
  value       = aws_cloudfront_origin_access_control.profile_oac.id
}

