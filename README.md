# CI/IaC Sample Project

Este repositório contém:
- ✅ Um exemplo simples de aplicação Python
- ⚙️ Pipeline de Integração Contínua (CI) com GitHub Actions
- ☁️ Scripts Terraform para provisionamento de infraestrutura na AWS

---

## 🧪 Aplicação Python

A aplicação está localizada na pasta `app/` e consiste em uma função simples com um teste automatizado.

### Requisitos
- Python 3.10+
- pip

### Instalação e Execução

```bash
cd app
pip install -r requirements.txt
python main.py
```
#### Executar Testes
```bash
cd app
pytest
```
## 🚀 Integração Contínua (CI) com GitHub Actions
O pipeline está configurado no arquivo:

```bash
.github/workflows/ci.yml
```
### Funcionalidades do pipeline:
- Instala dependências do Python
- Executa testes automatizados com pytest
- Roda automaticamente em cada push ou pull request na branch main

## ☁️ Provisionamento de Infraestrutura com Terraform
Scripts de IaC estão localizados em:

```
infra/
```
### Pré-requisitos
- Conta na AWS com credenciais válidas
- Terraform instalado (como instalar)

### Comandos para provisionar
```bash
cd infra

# Inicializa o projeto Terraform
terraform init

# Visualiza os recursos que serão criados
terraform plan

# Aplica as mudanças (cria a infraestrutura)
terraform apply
```
A configuração atual cria uma instância EC2 com a AMI padrão Amazon Linux 2 (us-east-1).

### Destruir a infraestrutura
```bash
terraform destroy
```

## 📦 Estrutura do Projeto
```bash
ci-iac-project/
├── app/                      # Aplicação Python
│   ├── main.py
│   ├── test_main.py
│   └── requirements.txt
├── infra/                    # Scripts Terraform
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── provider.tf
├── .github/workflows/        # GitHub Actions
│   └── ci.yml
└── README.md
```