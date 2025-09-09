.PHONY: help init plan apply destroy validate fmt clean

TERRAFORM_DIR = infra/
STATE_BUCKET = hello-devops-terraform-state

help:	## Mostra esta ajuda
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

init:	## Inicializa Terraform
	@echo "🚀 Inicializando Terraform..."
	terraform -chdir=$(TERRAFORM_DIR) init

plan:	## Cria plano de execução
	@echo "📋 Criando plano de execução..."
	terraform -chdir=$(TERRAFORM_DIR) plan -var-file="terraform.tfvars"

apply:	## Aplica mudanças na infraestrutura
	@echo "🔧 Aplicando mudanças..."
	terraform -chdir=$(TERRAFORM_DIR) apply -var-file="terraform.tfvars"

destroy:	## Destrói toda a infraestrutura
	@echo "💥 ATENÇÃO: Destruindo infraestrutura..."
	terraform -chdir=$(TERRAFORM_DIR) destroy -var-file="terraform.tfvars"

validate:	## Valida configuração Terraform
	@echo "✅ Validando configuração..."
	terraform -chdir=$(TERRAFORM_DIR) validate

fmt:	## Formata arquivos Terraform
	@echo "🎨 Formatando arquivos..."
	terraform -chdir=$(TERRAFORM_DIR) fmt -recursive

clean:	## Limpa arquivos temporários
	@echo "🧹 Limpando arquivos temporários..."
	find $(TERRAFORM_DIR) -name ".terraform" -type d -exec rm -rf {} +
	find $(TERRAFORM_DIR) -name "*.tfplan" -delete
	find $(TERRAFORM_DIR) -name ".terraform.lock.hcl" -delete

state-bucket:	## Cria bucket para estado do Terraform
	@echo "🪣 Criando bucket para estado..."
	aws s3 mb s3://$(STATE_BUCKET) --region us-east-1
	aws s3api put-bucket-versioning --bucket $(STATE_BUCKET) --versioning-configuration Status=Enabled
	aws s3api put-bucket-encryption --bucket $(STATE_BUCKET) --server-side-encryption-configuration \
		'{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'

configure-kubectl:	## Configura kubectl para o cluster
	@echo "⚙️ Configurando kubectl..."
	aws eks update-kubeconfig --region $$(terraform -chdir=$(TERRAFORM_DIR) output -raw aws_region) \
		--name $$(terraform -chdir=$(TERRAFORM_DIR) output -raw cluster_name)

ecr-login:	## Faz login no ECR
	@echo "🔐 Fazendo login no ECR..."
	aws ecr get-login-password --region $$(terraform -chdir=$(TERRAFORM_DIR) output -raw aws_region) | \
		docker login --username AWS --password-stdin $$(terraform -chdir=$(TERRAFORM_DIR) output -raw ecr_repository_url)

outputs:	## Mostra outputs importantes
	@echo "📊 Outputs da infraestrutura:"
	@terraform -chdir=$(TERRAFORM_DIR) output

cost-estimate:	## Estima custos (requer infracost)
	@echo "💰 Estimando custos..."
	@if command -v infracost >/dev/null 2>&1; then \
		infracost breakdown --path $(TERRAFORM_DIR) --terraform-var-file terraform.tfvars; \
	else \
		echo "❌ Infracost não está instalado. Instale com: curl -fsSL https://raw.githubusercontent.com/infracost/infracost/master/scripts/install.sh | sh"; \
	fi

setup:	## Setup inicial completo
	@echo "🎬 Setup inicial completo..."
	make state-bucket
	make init
	make plan

deploy:	## Deploy completo
	@echo "🚀 Deploy completo..."
	make apply
	make configure-kubectl
	@echo "✅ Deploy concluído! Execute 'kubectl get nodes' para verificar o cluster."

refresh:	## Atualiza estado atual
	@echo "🔄 Atualizando estado..."
	terraform -chdir=$(TERRAFORM_DIR) refresh -var-file="terraform.tfvars"