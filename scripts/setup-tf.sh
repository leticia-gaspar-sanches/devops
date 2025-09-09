set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Variáveis
PROJECT_NAME="hello-devops"
AWS_REGION="us-east-1"
STATE_BUCKET="${PROJECT_NAME}-terraform-state-$(date +%s)"

echo -e "${BLUE}🚀 Hello DevOps - Setup da Infraestrutura${NC}"
echo "=================================================="

# Verificar pré-requisitos
echo -e "${YELLOW}📋 Verificando pré-requisitos...${NC}"

# Verificar AWS CLI
if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI não encontrado. Instale com: brew install awscli${NC}"
    exit 1
fi

# Verificar Terraform
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}❌ Terraform não encontrado. Instale com: brew install terraform${NC}"
    exit 1
fi

# Verificar kubectl
if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}❌ kubectl não encontrado. Instale com: brew install kubectl${NC}"
    exit 1
fi

# Verificar credenciais AWS
echo -e "${YELLOW}🔐 Verificando credenciais AWS...${NC}"
if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ Credenciais AWS não configuradas. Execute: aws configure${NC}"
    exit 1
fi

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo -e "${GREEN}✅ AWS Account ID: ${ACCOUNT_ID}${NC}"

# Criar terraform.tfvars se não existir
echo -e "${YELLOW}📝 Configurando variáveis do Terraform...${NC}"
if [ ! -f "terraform/terraform.tfvars" ]; then
    echo -e "${BLUE}Criando terraform.tfvars...${NC}"
    
    read -p "Digite seu usuário do GitHub: " GITHUB_USER
    read -p "Digite o nome do repositório: " GITHUB_REPO
    
    cat > terraform/terraform.tfvars << EOF
# Configurações do projeto
project_name = "${PROJECT_NAME}"
environment  = "dev"
aws_region   = "${AWS_REGION}"

# Configurações de rede
vpc_cidr           = "10.0.0.0/16"
enable_nat_gateway = true
single_nat_gateway = true

# Configurações do EKS
cluster_version              = "1.28"
node_group_instance_types    = ["t3.small"]
node_group_min_size          = 1
node_group_max_size          = 3
node_group_desired_size      = 2

# GitHub repository
github_repository = "${GITHUB_USER}/${GITHUB_REPO}"
EOF
    echo -e "${GREEN}✅ terraform.tfvars criado${NC}"
else
    echo -e "${GREEN}✅ terraform.tfvars já existe${NC}"
fi

# Criar bucket para estado do Terraform
echo -e "${YELLOW}🪣 Criando bucket para estado do Terraform...${NC}"
if ! aws s3 ls "s3://${STATE_BUCKET}" &> /dev/null; then
    aws s3 mb "s3://${STATE_BUCKET}" --region ${AWS_REGION}
    
    # Habilitar versionamento
    aws s3api put-bucket-versioning \
        --bucket ${STATE_BUCKET} \
        --versioning-configuration Status=Enabled
    
    # Habilitar criptografia
    aws s3api put-bucket-encryption \
        --bucket ${STATE_BUCKET} \
        --server-side-encryption-configuration \
        '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
    
    echo -e "${GREEN}✅ Bucket ${STATE_BUCKET} criado${NC}"
    
    # Atualizar main.tf com o nome do bucket
    sed -i "s/hello-devops-terraform-state/${STATE_BUCKET}/g" terraform/main.tf
else
    echo -e "${GREEN}✅ Bucket já existe${NC}"
fi

# Inicializar Terraform
echo -e "${YELLOW}🔧 Inicializando Terraform...${NC}"
cd terraform/
terraform init

# Validar configuração
echo -e "${YELLOW}✅ Validando configuração...${NC}"
terraform validate
terraform fmt

# Mostrar plano
echo -e "${YELLOW}📋 Criando plano de execução...${NC}"
terraform plan -var-file="terraform.tfvars"

# Pergunta se quer aplicar
echo -e "${YELLOW}🤔 Deseja aplicar as mudanças agora? (y/N)${NC}"
read -r APPLY_NOW

if [[ $APPLY_NOW =~ ^[Yy]$ ]]; then
    echo -e "${BLUE}🚀 Aplicando infraestrutura...${NC}"
    terraform apply -var-file="terraform.tfvars"
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Infraestrutura criada com sucesso!${NC}"
        
        # Configurar kubectl
        echo -e "${YELLOW}⚙️ Configurando kubectl...${NC}"
        CLUSTER_NAME=$(terraform output -raw cluster_name)
        aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}
        
        # Verificar cluster
        echo -e "${YELLOW}🔍 Verificando cluster...${NC}"
        kubectl get nodes
        
        # Mostrar outputs importantes
        echo -e "${GREEN}📊 Informações importantes:${NC}"
        echo "=================================="
        terraform output
        
        echo -e "${BLUE}📝 Configure estes GitHub Secrets:${NC}"
        echo "AWS_ROLE_ARN: $(terraform output -raw github_actions_role_arn)"
        echo "AWS_REGION: ${AWS_REGION}"
        echo "EKS_CLUSTER_NAME: $(terraform output -raw cluster_name)"
        
        echo -e "${GREEN}🎉 Setup concluído com sucesso!${NC}"
    else
        echo -e "${RED}❌ Erro ao aplicar infraestrutura${NC}"
        exit 1
    fi
else
    echo -e "${BLUE}ℹ️ Para aplicar mais tarde, execute:${NC}"
    echo "cd terraform && terraform apply -var-file='terraform.tfvars'"
fi

echo -e "${GREEN}✨ Setup da infraestrutura finalizado!${NC}"