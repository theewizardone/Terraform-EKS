module "eks_aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.36.0"

  cluster_name                       = "my-eks-cluster"
  cluster_endpoint                   = data.aws_eks_cluster.cluster.endpoint
  cluster_certificate_authority_data = data.aws_eks_cluster.cluster.certificate_authority[0].data

  map_users = [
    {
      userarn  = "arn:aws:iam::522585361427:user/kenaiboy"
      username = "kenaiboy"
      groups   = ["system:masters"]
    }
  ]
}

data "aws_eks_cluster" "cluster" {
  name = "my-eks-cluster"
}
