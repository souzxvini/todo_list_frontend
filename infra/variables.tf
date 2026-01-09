variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "bucket_name" {
  type = string
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, staging, prod)"
  default     = "dev"
}

variable "price_class" {
  type        = string
  description = "Price class do CloudFront (PriceClass_100, PriceClass_200, PriceClass_All)"
  default     = "PriceClass_200"
}

variable "domain_name" {
  type        = string
  default     = "todolistsouzxvini.com"
  description = "Root domain name"
}

variable "profile_subdomain" {
  type        = string
  default     = "souzxvini"
  description = "Profile subdomain (e.g., my-profile.example.com)"
}

variable "certificate_arn" {
  type        = string
  default     = ""
  description = "ACM certificate ARN for CloudFront. Set via environment variable TF_VAR_certificate_arn or terraform.tfvars. Certificate must be in us-east-1 for CloudFront."
}
