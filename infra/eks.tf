module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = local.name
  cluster_version = var.cluster_version

  vpc_id                         = module.vpc.vpc_id
  subnet_ids                     = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  # OIDC Identity provider
  cluster_identity_providers = {
    sts = {
      client_id = "sts.amazonaws.com"
    }
  }

  # Managed Node Groups
  eks_managed_node_groups = {
    main = {
      name = "${local.name}-node-group"

      instance_types = var.node_group_instance_types

      # Cluster access entry
      enable_cluster_creator_admin_permissions = true

      min_size     = var.node_group_min_size
      max_size     = var.node_group_max_size
      desired_size = var.node_group_desired_size

      # Launch template configuration
      launch_template_name            = "${local.name}-node-group"
      launch_template_use_name_prefix = true

      remote_access = {
        ec2_ssh_key               = aws_key_pair.eks_nodes.key_name
        source_security_group_ids = [aws_security_group.remote_access.id]
      }

      # Node group configuration
      ami_type       = "AL2_x86_64"
      capacity_type  = "ON_DEMAND"
      disk_size      = 20

      # Taints and labels
      taints = {}
      labels = {
        Environment = var.environment
        NodeGroup   = "main"
      }

      update_config = {
        max_unavailable_percentage = 33
      }
    }
  }

  tags = local.tags
}

# Security Group para acesso remoto aos nodes
resource "aws_security_group" "remote_access" {
  name        = "${local.name}-remote-access"
  description = "Security group for remote access to EKS nodes"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.tags, {
    Name = "${local.name}-remote-access"
  })
}

# Key Pair para acesso SSH aos nodes
resource "aws_key_pair" "eks_nodes" {
  key_name   = "${local.name}-eks-nodes"
  public_key = file("~/.ssh/id_rsa.pub")  # Ajuste o caminho conforme necessário

  tags = local.tags
}