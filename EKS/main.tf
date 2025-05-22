# VPC Module
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  

  name            = "jenkins-vpc"
  cidr            = var.vpc_cidr
  azs             = data.aws_availability_zones.azs.names
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/elb"               = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/my-eks-cluster" = "shared"
    "kubernetes.io/role/internal-elb"      = "1"
  }
}

#─────────────────────────────────────────────────────────────────────────────
# 1) EKS cluster module (no map_users here)
#─────────────────────────────────────────────────────────────────────────────
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "my-eks-cluster"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    nodes = {
      instance_types = ["t2.small"]
      min_size       = 1
      max_size       = 5
      desired_size   = 2
    }
  }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

#─────────────────────────────────────────────────────────────────────────────
# 2) aws-auth sub-module (v20.36.0) to map IAM identities into RBAC
#─────────────────────────────────────────────────────────────────────────────
module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.36.0"

  # Required cluster info outputs from the main module
  cluster_name                       = module.eks.cluster_name
  cluster_endpoint                   = module.eks.cluster_endpoint
  cluster_certificate_authority_data = module.eks.cluster_certificate_authority_data

  # Grant the Jenkins IAM user full admin access
  map_users = [
    {
      userarn  = "arn:aws:iam::522585361427:user/kenaiboy"
      username = "kenaiboy"
      groups   = ["system:masters"]
    }
  ]
}
