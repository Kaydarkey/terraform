provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      Project     = "terraform-demo-project-1"
      Terraform   = "true"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-demo-project-1-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-demo-project-1-locks"
    encrypt        = true
  }
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "prod-vpc"
  vpc_cidr = "10.1.0.0/16"
  azs      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  
  private_subnets = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
  public_subnets  = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false  # For production, use multiple NAT gateways for HA

  tags = {
    Environment = "prod"
  }
}

module "security_groups" {
  source = "../../modules/security_group"

  vpc_id       = module.vpc.vpc_id
  name_prefix  = "prod"
  
  # Restrict SSH access in production
  ingress_cidr_blocks = ["10.0.0.0/8"]  # Assuming this is your corporate network
  
  tags = {
    Environment = "prod"
  }
}

module "ec2_app" {
  source = "../../modules/ec2"

  instance_name          = "prod-app-server"
  ami_id                 = "ami-0df368112825f8d8f" # Update with latest Ubuntu Server
  instance_type          = "t3.medium"  # Larger instance for production
  key_name               = "lamp"
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.security_groups.web_security_group_id]
  
  docker_image         = "nginx:stable"  # Use stable tag for production
  docker_container_port = 80
  docker_host_port     = 80

  tags = {
    Environment = "prod"
    Application = "demo"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name             = "prod-eks-cluster"
  cluster_version          = "1.25"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  cluster_security_group_id = module.security_groups.eks_cluster_security_group_id
  node_security_group_id   = module.security_groups.eks_nodes_security_group_id
  
  node_group_name  = "prod-node-group"
  instance_types   = ["t3.large"]  # Larger instances for production
  desired_size     = 3
  min_size         = 2
  max_size         = 5

  tags = {
    Environment = "prod"
  }
}