# Configurações básicas
project_name = "hello-devops"
environment  = "dev"
aws_region   = "us-east-1"

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

# GitHub repository (formato: owner/repository)
github_repository = "seu-usuario/hello-devops"