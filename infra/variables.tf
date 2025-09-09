variable "project_name" {
  description = "Nome do projeto"
  type        = string
  default     = "hello-devops"
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "aws_region" {
  description = "Região AWS"
  type        = string
  default     = "us-east-1"
}

variable "vpc_cidr" {
  description = "CIDR block para VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "cluster_version" {
  description = "Versão do Kubernetes"
  type        = string
  default     = "1.28"
}

variable "node_group_instance_types" {
  description = "Tipos de instância para worker nodes"
  type        = list(string)
  default     = ["t3.small"]
}

variable "node_group_min_size" {
  description = "Número mínimo de worker nodes"
  type        = number
  default     = 1
}

variable "node_group_max_size" {
  description = "Número máximo de worker nodes"
  type        = number
  default     = 3
}

variable "node_group_desired_size" {
  description = "Número desejado de worker nodes"
  type        = number
  default     = 2
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway"
  type        = bool
  default     = true
}

variable "single_nat_gateway" {
  description = "Usar apenas um NAT Gateway"
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames na VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar DNS support na VPC"
  type        = bool
  default     = true
}