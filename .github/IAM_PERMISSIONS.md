# Permissões IAM Necessárias para GitHub Actions

O workflow de deploy do frontend requer permissões adicionais na IAM Role do GitHub Actions para:

1. **Terraform**: Provisionar recursos S3 e CloudFront
2. **S3**: Upload de arquivos para o bucket do frontend
3. **CloudFront**: Criar invalidações de cache

## Permissões a Adicionar na IAM Policy

Se você estiver usando a IAM Role criada no `todo_list_contrato/infra/bootstrap`, você precisa adicionar as seguintes permissões à política `terraform_deploy_policy`:

### 1. Permissões S3 para o Bucket do Frontend

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:ListBucket",
    "s3:GetBucketLocation",
    "s3:GetBucketVersioning"
  ],
  "Resource": "arn:aws:s3:::SEU_BUCKET_NAME"
},
{
  "Effect": "Allow",
  "Action": [
    "s3:PutObject",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:PutObjectAcl"
  ],
  "Resource": "arn:aws:s3:::SEU_BUCKET_NAME/*"
}
```

### 2. Permissões CloudFront

```json
{
  "Effect": "Allow",
  "Action": [
    "cloudfront:CreateInvalidation",
    "cloudfront:GetInvalidation",
    "cloudfront:ListInvalidations",
    "cloudfront:GetDistribution",
    "cloudfront:ListDistributions"
  ],
  "Resource": "*"
}
```

### 3. Permissões Adicionais para Terraform (se necessário)

Para que o Terraform possa criar e gerenciar recursos CloudFront e S3:

```json
{
  "Effect": "Allow",
  "Action": [
    "cloudfront:CreateDistribution",
    "cloudfront:UpdateDistribution",
    "cloudfront:DeleteDistribution",
    "cloudfront:GetDistributionConfig",
    "cloudfront:CreateOriginAccessControl",
    "cloudfront:GetOriginAccessControl",
    "cloudfront:UpdateOriginAccessControl",
    "cloudfront:DeleteOriginAccessControl",
    "cloudfront:ListOriginAccessControls"
  ],
  "Resource": "*"
}
```

## Como Atualizar a IAM Policy

1. Acesse o arquivo `todo_list_contrato/infra/bootstrap/main.tf`
2. Adicione as permissões acima no bloco `terraform_deploy_policy`
3. Aplique as mudanças com `terraform apply`

**OU**

1. Acesse o IAM Console na AWS
2. Encontre a role `github-actions-terraform-deploy` (ou o nome definido em `var.role_name`)
3. Adicione as permissões acima na política inline ou crie uma nova política e anexe à role

## Variáveis do GitHub Actions Necessárias

Configure as seguintes variáveis no repositório do GitHub:

- `AWS_ROLE_ARN`: ARN da role IAM do GitHub Actions
- `AWS_REGION`: Região AWS (ex: us-east-1)
- `TF_STATE_BUCKET_NAME`: Nome do bucket S3 para state do Terraform
- `S3_BUCKET_NAME`: Nome do bucket S3 para o frontend (ex: todo-list-frontend-dev)
- `PROJECT_NAME`: Nome do projeto (padrão: todo-list-frontend)
- `ENVIRONMENT`: Ambiente (padrão: dev)

## Exemplo de Configuração Completa da IAM Policy

Você pode adicionar este bloco ao arquivo `todo_list_contrato/infra/bootstrap/main.tf` dentro do `terraform_deploy_policy`:

```hcl
# --- S3 Frontend Bucket Operations ---
{
  Effect = "Allow",
  Action = [
    "s3:ListBucket",
    "s3:GetBucketLocation",
    "s3:GetBucketVersioning"
  ],
  Resource = "arn:aws:s3:::${var.frontend_bucket_name}"
},
{
  Effect = "Allow",
  Action = [
    "s3:PutObject",
    "s3:GetObject",
    "s3:DeleteObject",
    "s3:PutObjectAcl"
  ],
  Resource = "arn:aws:s3:::${var.frontend_bucket_name}/*"
},

# --- CloudFront Operations ---
{
  Effect = "Allow",
  Action = [
    "cloudfront:CreateInvalidation",
    "cloudfront:GetInvalidation",
    "cloudfront:ListInvalidations",
    "cloudfront:GetDistribution",
    "cloudfront:ListDistributions",
    "cloudfront:CreateDistribution",
    "cloudfront:UpdateDistribution",
    "cloudfront:DeleteDistribution",
    "cloudfront:GetDistributionConfig",
    "cloudfront:CreateOriginAccessControl",
    "cloudfront:GetOriginAccessControl",
    "cloudfront:UpdateOriginAccessControl",
    "cloudfront:DeleteOriginAccessControl",
    "cloudfront:ListOriginAccessControls"
  ],
  Resource = "*"
}
```

**Nota**: Se você usar o padrão `*` no Resource para S3 operations do bootstrap atual, algumas dessas permissões já podem estar cobertas. Ajuste conforme necessário.

