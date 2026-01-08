variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

variable "project_name" {
  type        = string
  description = "Nome do projeto (prefixo dos recursos)"
  default     = "todo-list-frontend"
}

variable "environment" {
  type        = string
  description = "Ambiente (dev, staging, prod)"
  default     = "dev"
}

variable "s3_bucket_name" {
  type        = string
  description = "Nome do bucket S3 para hospedar o frontend"
}

variable "api_gateway_url" {
  type        = string
  description = "URL da API Gateway (opcional)"
  default     = ""
}

variable "certificate_arn" {
  type        = string
  description = "ARN do certificado ACM para domínio customizado (opcional)"
  default     = ""
}

variable "domain_name" {
  type        = string
  description = "Domínio customizado para CloudFront (opcional)"
  default     = ""
}

variable "price_class" {
  type        = string
  description = "Price class do CloudFront (PriceClass_100, PriceClass_200, PriceClass_All)"
  default     = "PriceClass_200"
}

variable "enable_create_resources" {
  type        = bool
  description = "Se true, cria recursos se não existirem. Se false, assume que já existem"
  default     = true
}

