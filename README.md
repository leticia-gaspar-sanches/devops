# Hello DevOps - Projeto CI/CD com Infraestrutura como Código

Um projeto de CI/CD usando GitHub Actions, Docker, Kubernetes (EKS) e Terraform para provisionar toda a infraestrutura AWS.

## 📋 Funcionalidade

O projeto possui apenas uma função Python:
```python
def hello():
    return "Hello, DevOps!"
```

## 🛠️ Stack Tecnológica

### Aplicação
- **Python 3.11** - Linguagem de programação (sem dependências externas)
- **Docker** - Containerização
- **pytest** - Testes automatizados

### Infraestrutura (AWS)
- **EKS** - Kubernetes gerenciado
- **ECR** - Registry de containers
- **VPC** - Rede isolada
- **IAM** - Controle de acesso com OIDC

### DevOps
- **Terraform** - Infraestrutura como Código (IaC)
- **GitHub Actions** - CI/CD Pipeline
- **kubectl** - Gerenciamento Kubernetes

## 🏗️ Arquitetura da Infraestrutura

```
┌─────────────────────────────────────────────────────────┐
│                        AWS Cloud                        │
│                                                         │
│  ┌─────────────────────────────────────────────────┐   │
│  │                    VPC                          │   │
│  │                                                 │   │
│  │  ┌─────────────┐    ┌─────────────────────┐    │   │
│  │  │   Public    │    │      Private        │    │   │
│  │  │   Subnets   │    │      Subnets        │    │   │
│  │  │             │    │                     │    │   │
│  │  │ NAT Gateway │────│   EKS Worker Nodes  │    │   │
│  │  │             │    │                     │    │   │
│  │  └─────────────┘    └─────────────────────┘    │   │
│  │                                                 │   │
│  │                EKS Control Plane                │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌─────────────┐                                       │
│  │     ECR     │ ←── GitHub Actions (OIDC)             │
│  │ Repository  │                                       │
│  └─────────────┘                                       │
└─────────────────────────────────────────────────────────┘
```

## 🚀 Setup Rápido

### 1. Pré-requisitos
```bash
# Instalar ferramentas
brew install terraform awscli kubectl

# Configurar AWS
aws configure
```

### 2. Deploy da Infraestrutura
```bash
# Clone o repositório
git clone <devops>
cd devops

# Execute o setup automático
chmod +x scripts/setup-terraform.sh
./scripts/setup-terraform.sh
```

### 3. Configurar GitHub Secrets
Após o deploy, configure no GitHub:
```
AWS_ROLE_ARN: arn:aws:iam::123456789:role/hello-devops-dev-github-actions
AWS_REGION: us-east-1
EKS_CLUSTER_NAME: hello-devops-dev
```

### 4. Executar Pipeline
```bash
# Fazer push para main
git add .
git commit -m "feat: deploy inicial"
git push origin main
```

## 📁 Estrutura do Projeto

```
devops/
├── app/
│   ├── main.py               # Script Python principal               
│   ├── requirements.txt      # Arquivo com as dependências do projeto
│   └── test_main.py          # Testes da função hello()
├── Dockerfile                # Container
├── infra/                    # Infraestrutura como Código (IaC)
│   ├── main.tf               # Configuração principal
│   ├── variables.tf          # Variáveis
│   ├── vpc.tf                # Rede (VPC, subnets)
│   ├── eks.tf                # Cluster Kubernetes
│   ├── ecr.tf                # Repositório Docker
│   ├── iam.tf                # Roles e políticas
│   ├── outputs.tf            # Outputs
│   ├── terraform.tfvars      # Valores das variáveis
├── k8s/
│   ├── deployment.yml       # Deployment Kubernetes  
│   └── job.yml              # Job Kubernetes
├── scripts/
│   └── setup-tf.sh           # Setup automático
├── .github/
│   └── workflows/
│       ├── ci-cd.yml         # Pipeline original (Docker Hub)
│       └── ci-cd-aws.yml     # Pipeline AWS (ECR + EKS)
└── README.md                 # Documentação
```

## 🏃‍♂️ Comandos Úteis

### Terraform
```bash
cd terraform/

# Ver plano
make plan

# Aplicar mudanças
make apply

# Destruir tudo
make destroy

# Ver outputs
make outputs
```

### Kubernetes
```bash
# Configurar kubectl
make configure-kubectl

# Executar job manualmente
kubectl apply -f k8s/job.yml
kubectl logs job/hello-devops-job

# Ver pods
kubectl get pods -l app=hello-devops
```

### Local
```bash
# Executar localmente
python main.py

# Executar com Docker
docker build -t hello-devops .
docker run hello-devops

# Executar testes
python -m pytest tests/ -v
```

> # Hello DevOps

Um projeto de CI/CD usando GitHub Actions, Docker e Kubernetes com apenas uma função Python que imprime "Hello, DevOps!".

## 📋 Funcionalidade

O projeto possui apenas uma função Python:
```python
def hello():
    return "Hello, DevOps!"
```

## 🛠️ Tecnologias Utilizadas

- **Python 3.11** - Linguagem de programação (sem dependências externas)
- **Docker** - Containerização
- **Kubernetes** - Orquestração de containers (usando Jobs)
- **GitHub Actions** - CI/CD Pipeline
- **pytest** - Testes automatizados

## 🏃‍♂️ Como Executar Localmente

### Executar diretamente com Python
```bash
python main.py
# Output: Hello, DevOps!
```

### Executar com Docker
```bash
docker build -t hello-devops .
docker run hello-devops
# Output: Hello, DevOps!
```

## ☁️ Deploy no Kubernetes

Como é um script simples, usamos **Kubernetes Jobs** ao invés de Deployments:

### 1. Executar como Job (execução única)
```bash
kubectl apply -f k8s/job.yml
kubectl logs job/hello-devops-job
```

### 2. Executar como Deployment (execução contínua)
```bash
kubectl apply -f k8s/deployment.yml
kubectl logs deployment/hello-devops-app
```

### 3. Verificar status
```bash
kubectl get jobs
kubectl get pods -l app=hello-devops
```

## 🔄 Pipeline CI/CD

O pipeline é executado automaticamente e contém:

1. **Test** - Testa a função `hello()`
2. **Build and Push** - Constrói imagem Docker minimalista
3. **Deploy** - Executa como Kubernetes Job e mostra logs

### Configuração de Secrets no GitHub:
```bash
DOCKER_USERNAME     # Usuário do Docker Hub
DOCKER_PASSWORD     # Senha do Docker Hub  
KUBE_CONFIG        # Arquivo kubeconfig (base64)
```

## 🧪 Executar Testes

```bash
python -m pytest tests/ -v
```

Os testes verificam:
- Se `hello()` retorna "Hello, DevOps!"
- Se a string não está vazia

## 📦 Container Details

O Dockerfile é extremamente simples:
- Imagem base: `python:3.11-slim`
- Sem dependências externas
- Apenas copia `main.py` e executa

## 🎯 Por que Kubernetes Jobs?

Como nosso script executa uma vez e termina, usamos **Jobs** ao invés de **Deployments**:
- **Job**: Executa uma vez e para
- **Deployment**: Mantém o processo rodando continuamente

## 🔧 Comandos Úteis

```bash
# Executar localmente
python main.py

# Build Docker
docker build -t hello-devops .
docker run hello-devops

# Executar Job no Kubernetes  
kubectl apply -f k8s/job.
kubectl logs job/hello-devops-job

# Limpar Job
kubectl delete job hello-devops-job

# Ver logs em tempo real
kubectl logs -f job/hello-devops-job
```