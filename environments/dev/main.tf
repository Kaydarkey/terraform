provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      Project     = "terraform-demo-project-1"
      Terraform   = "true"
    }
  }
}

terraform {
  backend "s3" {
    bucket         = "terraform-demo-project-1-state"
    key            = "dev/terraform.tfstate"
    region         = "eu-west-1"
    use_lockfile = true
    encrypt        = true
  }
}

module "vpc" {
  source = "../../modules/vpc"

  vpc_name = "dev-vpc"
  vpc_cidr = "10.0.0.0/16"
  azs      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "dev"
  }
}

module "security_groups" {
  source = "../../modules/security_group"

  vpc_id       = module.vpc.vpc_id
  name_prefix  = "dev"
  
  tags = {
    Environment = "dev"
  }
}

module "ec2_app" {
  source               = "../../modules/ec2"
  ami_id               = "ami-0df368112825f8d8f" #AMI ID for eu-west-1
  instance_type        = "t2.micro"
  subnet_id            = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.security_groups.web_security_group_id]
  key_name             = "flask" # Optional, replace or remove
  instance_name        = "my-app-instance"
  docker_image         = "nginx:latest"
  docker_container_port = "80"
  docker_host_port     = "80"
  tags = {
    Environment = "dev"
    Project     = "my-app"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name             = "dev-eks-cluster"
  cluster_version          = "1.25"
  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnet_ids
  cluster_security_group_id = module.security_groups.eks_cluster_security_group_id
  node_security_group_id   = module.security_groups.eks_nodes_security_group_id
  
  node_group_name  = "dev-node-group"
  instance_types   = ["t3.medium"]
  desired_size     = 2
  min_size         = 1
  max_size         = 3

  tags = {
    Environment = "dev"
  }
}