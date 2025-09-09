output "github_actions_role_arn" {
  description = "ARN da role do GitHub Actions"
  value       = aws_iam_role.github_actions.arn
}

output "pod_service_account_role_arn" {
  description = "ARN da role do service account dos pods"
  value       = aws_iam_role.hello_devops_pod.arn
}

# Comandos úteis
output "configure_kubectl" {
  description = "Comando para configurar kubectl"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "ecr_login_command" {
  description = "Comando para fazer login no ECR"
  value       = "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${aws_ecr_repository.hello_devops.repository_url}"
}

output "docker_build_command" {
  description = "Comando para build e push da imagem"
  value       = <<EOF
docker build -t ${aws_ecr_repository.hello_devops.repository_url}:latest .
docker push ${aws_ecr_repository.hello_devops.repository_url}:latest
EOF
}