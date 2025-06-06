resource "aws_instance" "devops_example" {
  ami           = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (us-east-1)
  instance_type = var.instance_type

  tags = {
    Name = "DevOpsInstance"
  }
}