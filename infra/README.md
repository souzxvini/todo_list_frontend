# Todo List Frontend - Infrastructure

Infraestrutura Terraform para provisionar S3 bucket e CloudFront distribution para hospedar o frontend Angular.

## Estrutura

```
infra/
├── main.tf          # Recursos principais (S3, CloudFront, OAC)
├── outputs.tf       # Outputs (CloudFront URL, S3 bucket name)
├── variables.tf     # Variáveis
├── provider.tf      # Configuração do provider AWS
├── versions.tf      # Versões do Terraform e providers
└── backend.tf       # Backend S3 (reutilizando bucket e DynamoDB existentes)
```

## Recursos Provisionados

- **S3 Bucket**: Bucket privado para hospedar arquivos estáticos do frontend
- **CloudFront Distribution**: CDN para servir o conteúdo do S3
- **Origin Access Control (OAC)**: Permite que CloudFront acesse o bucket S3 privado
- **Bucket Policy**: Restringe acesso ao bucket apenas via CloudFront

## Backend Configuration

O backend reutiliza o mesmo bucket S3 e DynamoDB já utilizados pelos outros repositórios:

- **Bucket S3**: Variável `TF_STATE_BUCKET_NAME` (mesmo usado em `todo_list_contrato` e `todo_list_api`)
- **DynamoDB Table**: `terraform-locks` (mesma tabela usada pelos outros repositórios)
- **State Key**: `todolist/dev/frontend.tfstate`

## Criação Condicional

Os recursos são criados **apenas se não existirem na AWS**. Isso é controlado pela variável `enable_create_resources`:

- Se `enable_create_resources = true` (padrão): Cria recursos se não existirem
- Se `enable_create_resources = false`: Assume que recursos já existem e não cria

## Deploy

### Pré-requisitos

1. AWS CLI configurado com credenciais
2. Terraform >= 1.6.0 instalado
3. Variáveis de ambiente configuradas:
   - `TF_STATE_BUCKET_NAME`: Nome do bucket S3 para state (mesmo dos outros repositórios)
   - `AWS_REGION`: Região AWS (padrão: us-east-1)

### 1. Inicializar Terraform

```bash
cd todo_list_frontend/infra
terraform init \
  -backend-config="bucket=$TF_STATE_BUCKET_NAME" \
  -backend-config="key=todolist/dev/frontend.tfstate" \
  -backend-config="region=$AWS_REGION" \
  -backend-config="dynamodb_table=terraform-locks" \
  -backend-config="encrypt=true"
```

### 2. Validar configuração

```bash
terraform validate
```

### 3. Planejar mudanças

```bash
terraform plan \
  -var="s3_bucket_name=todo-list-frontend-dev" \
  -var="project_name=todo-list-frontend" \
  -var="environment=dev"
```

### 4. Aplicar mudanças

```bash
terraform apply \
  -var="s3_bucket_name=todo-list-frontend-dev" \
  -var="project_name=todo-list-frontend" \
  -var="environment=dev"
```

### 5. Obter outputs

Após aplicar, você pode obter as URLs do CloudFront:

```bash
terraform output cloudfront_url
terraform output cloudfront_distribution_id
terraform output s3_bucket_name
```

## Variáveis

### Obrigatórias

- `s3_bucket_name` - Nome do bucket S3 (ex: "todo-list-frontend-dev")

### Opcionais

- `project_name` (default: "todo-list-frontend") - Prefixo dos recursos
- `aws_region` (default: "us-east-1") - Região AWS
- `environment` (default: "dev") - Ambiente (dev, staging, prod)
- `enable_create_resources` (default: true) - Se true, cria recursos se não existirem
- `api_gateway_url` (default: "") - URL da API Gateway (opcional)
- `certificate_arn` (default: "") - ARN do certificado ACM para domínio customizado
- `domain_name` (default: "") - Domínio customizado para CloudFront
- `price_class` (default: "PriceClass_200") - Price class do CloudFront

## Outputs

- `cloudfront_distribution_id` - ID da distribuição CloudFront
- `cloudfront_domain_name` - Nome de domínio do CloudFront
- `cloudfront_url` - URL completa com https://
- `cloudfront_arn` - ARN da distribuição CloudFront
- `s3_bucket_name` - Nome do bucket S3
- `s3_bucket_id` - ID do bucket S3
- `s3_bucket_arn` - ARN do bucket S3
- `s3_bucket_domain_name` - Nome de domínio do bucket S3
- `oac_id` - ID do Origin Access Control (OAC)

## Features

### SPA Routing

O CloudFront está configurado para suportar Angular Router, redirecionando erros 404 e 403 para `/index.html` com status 200.

### Segurança

- Bucket S3 privado (sem acesso público direto)
- Public Access Block habilitado
- Acesso apenas via CloudFront usando Origin Access Control (OAC)
- HTTPS obrigatório (redireciona HTTP para HTTPS)

### Cache

- Default TTL: 3600 segundos (1 hora)
- Max TTL: 86400 segundos (24 horas)
- Compressão habilitada

## Deploy do Frontend

### Deploy Automático via GitHub Actions

O repositório inclui um workflow do GitHub Actions (`.github/workflows/deploy.yml`) que automatiza todo o processo de deploy:

1. **Provisiona a infraestrutura** com Terraform (se necessário)
2. **Faz build do Angular** em produção
3. **Faz upload dos arquivos** para o S3
4. **Invalida o cache** do CloudFront

#### Configuração do GitHub Actions

##### 1. Configurar Variáveis do Repositório

Acesse: `Settings > Secrets and variables > Actions > Variables` e configure:

- `AWS_ROLE_ARN`: ARN da role IAM do GitHub Actions
- `AWS_REGION`: Região AWS (ex: `us-east-1`)
- `TF_STATE_BUCKET_NAME`: Nome do bucket S3 para state do Terraform
- `S3_BUCKET_NAME`: Nome do bucket S3 para o frontend (ex: `todo-list-frontend-dev`)
- `PROJECT_NAME`: Nome do projeto (padrão: `todo-list-frontend`)
- `ENVIRONMENT`: Ambiente (padrão: `dev`)

##### 2. Configurar Permissões IAM

A IAM Role do GitHub Actions precisa ter permissões adicionais para S3 e CloudFront. Veja `.github/IAM_PERMISSIONS.md` para detalhes completos.

**Resumo rápido das permissões necessárias**:
- **S3**: `ListBucket`, `PutObject`, `GetObject`, `DeleteObject` no bucket do frontend
- **CloudFront**: `CreateInvalidation`, `GetDistribution`, `ListDistributions`, etc.

##### 3. Trigger do Workflow

O workflow é acionado automaticamente quando há push para `master` ou `main` que afeta:
- `src/**`
- `infra/**`
- `.github/workflows/deploy.yml`
- `angular.json`, `package.json`, `package-lock.json`

### Deploy Manual (Alternativa)

Se preferir fazer deploy manual sem GitHub Actions:

1. **Build do Angular**:
   ```bash
   ng build --configuration production
   ```

2. **Upload para S3**:
   ```bash
   aws s3 sync dist/todo_list_frontend/browser/ s3://<bucket-name>/ --delete
   ```

3. **Invalidar cache do CloudFront**:
   ```bash
   aws cloudfront create-invalidation \
     --distribution-id <distribution-id> \
     --paths "/*"
   ```

## Notas

- Os recursos são criados apenas na primeira execução se não existirem
- Para recriar recursos, defina `enable_create_resources = true` e remova recursos existentes manualmente primeiro
- O bucket S3 usa versionamento habilitado para backup
- A criptografia server-side usa AES256

