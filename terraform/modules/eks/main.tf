variable "cluster_name"        {}
variable "vpc_id"              {}
variable "private_subnets"     { type = list(string) }
variable "node_instance_type"  { default = "t3.medium" }
variable "desired_size"        { default = 2 }

# NOTE: for a real build, swap this for the terraform-aws-modules/eks/aws module —
# writing the full IAM/OIDC wiring by hand is a good learning exercise once,
# but pin the community module for anything you'd actually run in prod.

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  vpc_config {
    subnet_ids = var.private_subnets
  }
  version = "1.30"
}

resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "eks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "cluster_policy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_node_group" "default" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "${var.cluster_name}-default"
  node_role_arn   = aws_iam_role.node.arn
  subnet_ids      = var.private_subnets
  instance_types  = [var.node_instance_type]
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.desired_size + 2
    min_size     = 1
  }
}

resource "aws_iam_role" "node" {
  name = "${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  url             = aws_eks_cluster.this.identity[0].oidc[0].issuer
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
}

output "cluster_name"            { value = aws_eks_cluster.this.name }
output "cluster_endpoint"        { value = aws_eks_cluster.this.endpoint }
output "oidc_provider_arn"       { value = aws_iam_openid_connect_provider.this.arn }
output "oidc_provider_url"       { value = aws_iam_openid_connect_provider.this.url }
output "node_security_group_id"  { value = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id }
