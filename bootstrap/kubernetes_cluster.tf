
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token = data.aws_eks_cluster_auth.cluster.token
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "3.0.0"

  name = "${var.eks_cluster_name}-vpc"
  azs = data.aws_availability_zones.available.names
  cidr = "172.16.0.0/16"
  private_subnets = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  public_subnets = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_nat_gateway = true
  single_nat_gateway = true
  enable_dns_hostnames = true

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = "1"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    "kubernetes.io/role/elb" = "1"
  }
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "16.1.0"

  cluster_name = var.eks_cluster_name
  cluster_version = "1.19"

  subnets = module.vpc.private_subnets
  vpc_id = module.vpc.vpc_id

  node_groups = {
    first = {
      instance_types = ["t2.micro"]
      desired_capacity = 3
      min_capacity = 3
      max_capacity = 5
    }
  }

  write_kubeconfig = true
  config_output_path = "./"

  map_roles = [
    {
      rolearn = var.build-role-arn
      username = "buildrole"
      groups = ["system:masters"]
    }
  ]
}
