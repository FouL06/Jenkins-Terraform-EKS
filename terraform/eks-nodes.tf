resource "aws_iam_role" "eks_nodes_role" {
  name = "eks_nodes_role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "eks_nodes_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "eks_nodes_CNI_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_iam_role_policy_attachment" "eks_nodes_registryReadOnly_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_eks_node_group" "eks_nodes_group" {
  cluster_name    = aws_eks_cluster.jenkins_eks_cluster.name
  node_group_name = "jenkins_eks_nodes"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn

  subnet_ids = [
    aws_subnet.jenkins_private_subnet_1.id,
    aws_subnet.jenkins_private_subnet_2.id
  ]

  capacity_type  = "ON_DEMAND"
  instance_types = [var.instance_types]
  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = var.eks_role
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_nodes_policy,
    aws_iam_role_policy_attachment.eks_nodes_CNI_policy,
    aws_iam_role_policy_attachment.eks_nodes_registryReadOnly_policy
  ]

  tags = {
    Owner = var.owner_tag
  }
}
