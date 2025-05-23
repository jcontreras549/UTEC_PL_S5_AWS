module "vpc" {
  source = "../../modules/vpc"

  name            = "eks-vpc"
  cidr            = "10.0.0.0/16"
  azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true

  tags = {
    Environment = "demo"
    Terraform   = "true"
  }
}

module "ec2" {
  source             = "../../modules/ec2"
  ami                = "ami-0c02fb55956c7d316"
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.public_subnets[0]   # <--- Aquí sI puedes usarlo
  key_name           = var.key_name
  security_group_ids = []
  tags = {
    Name        = "ec2-demo"
    Environment = "demo"
  }
}

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnets
  key_name        = var.key_name

  tags = {
    Environment = "demo"
    Terraform   = "true"
  }
}

module "ecr_repo" {
  source           = "../../modules/ecr"
  ecr_name         = ["frontend", "backend", "auth"]
  tags             = var.tags
  image_mutability = "IMMUTABLE"
}