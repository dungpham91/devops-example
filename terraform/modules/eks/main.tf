data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_eks_cluster_auth" "eks_cluster_auth" {
  name       = aws_eks_cluster.eks_cluster.name
  depends_on = [aws_eks_cluster.eks_cluster]
}

data "aws_iam_policy" "AmazonEC2ContainerRegistryPullOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

data "aws_iam_policy" "AmazonEKSBlockStoragePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSBlockStoragePolicy"
}

data "aws_iam_policy" "AmazonEKSClusterPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

data "aws_iam_policy" "AmazonEKSComputePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSComputePolicy"
}

data "aws_iam_policy" "AmazonEKSLoadBalancingPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
}

data "aws_iam_policy" "AmazonEKSNetworkingPolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSNetworkingPolicy"
}

data "aws_iam_policy" "AmazonEKSWorkerNodePolicy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

data "aws_iam_policy" "AmazonEKS_CNI_Policy" {
  arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "tls_certificate" "eks_cluster_sa_tls" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

locals {
  eks_custom_ami_userdata_templates = {
    "bootstrap" = templatefile("${path.module}/../../templates/bootstrap.sh.tpl", { cluster_name = aws_eks_cluster.eks_cluster.name }),
    "nodeadm" = templatefile("${path.module}/../../templates/nodeadm.yml.tpl", {
      cluster_name         = aws_eks_cluster.eks_cluster.name,
      endpoint             = aws_eks_cluster.eks_cluster.endpoint,
      certificateAuthority = aws_eks_cluster.eks_cluster.certificate_authority[0].data,
      cidr                 = aws_eks_cluster.eks_cluster.kubernetes_network_config[0].service_ipv4_cidr
    }),
  }
}

#------------------------------------------------------------------------------
# Security Groups
#------------------------------------------------------------------------------
resource "aws_security_group" "eks_node_sg" {
  name        = "${var.project}-${var.environment}-eks-node-sg"
  vpc_id      = var.vpc_id
  description = "Security group for EKS nodes"

  ingress {
    description = "Allow all traffic from VPC CIDR"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.vpc_cidr
  }

  ingress {
    description     = "Allow traffic from EKS Control Plane SG"
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id]
  }

  egress {
    description = "Allow all traffic to all destinations"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project}-${var.environment}-eks-node-sg"
    }
  )
}

resource "aws_security_group_rule" "eks_control_plane_ingress_rule" {
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.eks_node_sg.id
  description              = "Allow traffic from EKS node group to control plane"

  depends_on = [
    aws_security_group.eks_node_sg,
    aws_eks_cluster.eks_cluster
  ]
}

#------------------------------------------------------------------------------
# IAM Resources
#------------------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name                  = "${var.project}_${var.environment}_eks_cluster_role"
  description           = "IAM role for EKS cluster"
  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ],
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSBlockStoragePolicy" {
  policy_arn = data.aws_iam_policy.AmazonEKSBlockStoragePolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
  policy_arn = data.aws_iam_policy.AmazonEKSClusterPolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSComputePolicy" {
  policy_arn = data.aws_iam_policy.AmazonEKSComputePolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSLoadBalancingPolicy" {
  policy_arn = data.aws_iam_policy.AmazonEKSLoadBalancingPolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSNetworkingPolicy" {
  policy_arn = data.aws_iam_policy.AmazonEKSNetworkingPolicy.arn
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_iam_role" "eks_node_group_role" {
  name        = "${var.project}_${var.environment}_eks_node_group_role"
  description = "IAM role for EKS node group"

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

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEC2ContainerRegistryPullOnly" {
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerRegistryPullOnly.arn
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKSWorkerNodePolicy" {
  policy_arn = data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonEKS_CNI_Policy" {
  policy_arn = data.aws_iam_policy.AmazonEKS_CNI_Policy.arn
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_role_policy_attachment" "eks_node_group_AmazonSSMManagedInstanceCore" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role       = aws_iam_role.eks_node_group_role.name
}

resource "aws_iam_openid_connect_provider" "eks_cluster_sa_oidc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster_sa_tls.certificates[0].sha1_fingerprint]
  url             = data.tls_certificate.eks_cluster_sa_tls.url
}

data "aws_iam_policy_document" "eks_cluster_sa_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks_cluster_sa_oidc_provider.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks_cluster_sa_oidc_provider.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_cluster_serviceaccount_role" {
  name               = "${var.project}_${var.environment}_eks_serviceaccount_role"
  description        = "IAM role for EKS service account"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_sa_assume_role_policy.json
}

resource "aws_iam_policy" "eks_cluster_serviceaccount_vpc_cni_policy" {
  name = "${var.project}_${var.environment}_EKSClusterServiceAccountVPCCniPolicy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:AssignPrivateIpAddresses",
          "ec2:AttachNetworkInterface",
          "ec2:CreateNetworkInterface",
          "ec2:DeleteNetworkInterface",
          "ec2:DescribeInstances",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DetachNetworkInterface",
          "ec2:ModifyNetworkInterfaceAttribute",
          "ec2:UnassignPrivateIpAddresses"
        ],
        Effect = "Allow",
        Resource = [
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:network-interface/*",
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_serviceaccount_vpc_cni_policy_attachment" {
  policy_arn = aws_iam_policy.eks_cluster_serviceaccount_vpc_cni_policy.arn
  role       = aws_iam_role.eks_cluster_serviceaccount_role.name
}

resource "aws_iam_role" "ebs_csi_driver_role" {
  name        = "${var.project}_${var.environment}_ebs_csi_driver_role"
  description = "IAM role for EBS CSI driver"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_cluster_sa_oidc_provider.arn
        },
        Effect = "Allow",
        Condition = {
          StringEquals = {
            "${replace(aws_iam_openid_connect_provider.eks_cluster_sa_oidc_provider.url, "https://", "")}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "ebs_csi_driver_policy" {
  name        = "${var.project}_${var.environment}_ebs_csi_driver_policy"
  description = "IAM policy for EBS CSI driver"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "ec2:AttachVolume",
          "ec2:CreateSnapshot",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteSnapshot",
          "ec2:DeleteTags",
          "ec2:DeleteVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeInstances",
          "ec2:DescribeSnapshots",
          "ec2:DescribeTags",
          "ec2:DescribeVolumes",
          "ec2:DetachVolume",
          "ec2:ModifyVolume"
        ],
        Effect   = "Allow",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy_attachment" {
  policy_arn = aws_iam_policy.ebs_csi_driver_policy.arn
  role       = aws_iam_role.ebs_csi_driver_role.name
}

#------------------------------------------------------------------------------
# EKS Resources
#------------------------------------------------------------------------------
resource "aws_eks_cluster" "eks_cluster" {
  name     = "${var.project}-${var.environment}-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn
  version  = var.eks_cluster_version

  encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = var.kms_key_arn
    }
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = var.public_subnets
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  bootstrap_self_managed_addons = true

  timeouts {
    delete = "30m"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSBlockStoragePolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSComputePolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSLoadBalancingPolicy,
    aws_iam_role_policy_attachment.eks_cluster_AmazonEKSNetworkingPolicy,
  ]

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project}-${var.environment}-eks-cluster"
    }
  )
}

resource "aws_launch_template" "eks_node_group_launch_template" {
  name_prefix            = "${var.project}-${var.environment}-eks-ng-"
  image_id               = var.custom_ami_id
  instance_type          = var.node_instance_type
  update_default_version = true

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
    }
  }

  ebs_optimized = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "optional"
    http_put_response_hop_limit = 2
    instance_metadata_tags      = "enabled"
  }

  vpc_security_group_ids = [aws_security_group.eks_node_sg.id]
  user_data              = base64encode(local.eks_custom_ami_userdata_templates["nodeadm"])

  tag_specifications {
    resource_type = "instance"
    tags = merge(
      var.default_tags,
      {
        Name = "${var.project}-${var.environment}-eks-ng-node"
      }
    )
  }
}

# EKS Node Group (Managed)
resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "${var.project}-${var.environment}-${var.node_group_name}"
  node_role_arn   = aws_iam_role.eks_node_group_role.arn
  subnet_ids      = var.private_subnets
  capacity_type   = upper(var.node_capacity_type)

  launch_template {
    id      = aws_launch_template.eks_node_group_launch_template.id
    version = aws_launch_template.eks_node_group_launch_template.latest_version
  }

  scaling_config {
    desired_size = var.node_group_desired_capacity
    min_size     = var.node_group_min_size
    max_size     = var.node_group_max_size
  }

  update_config {
    max_unavailable_percentage = 25
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_node_group_AmazonEC2ContainerRegistryPullOnly,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.eks_node_group_AmazonSSMManagedInstanceCore
  ]
}

#------------------------------------------------------------------------------
# EKS Addons
#------------------------------------------------------------------------------
resource "aws_eks_addon" "addon_kube_proxy" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "kube-proxy"
  addon_version = "v1.32.0-eksbuild.2"
  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}

resource "aws_eks_addon" "addon_vpc_cni" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "vpc-cni"
  addon_version = "v1.19.2-eksbuild.1"
  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}

resource "aws_eks_addon" "addon_coredns" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "coredns"
  addon_version = "v1.11.4-eksbuild.2"
  depends_on = [
    aws_eks_node_group.eks_node_group
  ]
}

resource "aws_eks_addon" "addon_ebs_csi_driver" {
  cluster_name  = aws_eks_cluster.eks_cluster.name
  addon_name    = "aws-ebs-csi-driver"
  addon_version = "v1.39.0-eksbuild.1"
  depends_on = [
    aws_eks_node_group.eks_node_group,
    aws_iam_role_policy_attachment.ebs_csi_driver_policy_attachment
  ]
}
