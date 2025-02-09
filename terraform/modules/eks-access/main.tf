data "aws_caller_identity" "current" {}

locals {
  default_principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/cloud_user"
}

resource "aws_eks_access_entry" "eks_access_entry" {
  cluster_name      = "${var.project}-${var.environment}-eks-cluster"
  principal_arn     = var.principal_arn == null ? local.default_principal_arn : var.principal_arn
  kubernetes_groups = var.kubernetes_groups
  type              = var.access_entry_type
}

resource "aws_eks_access_policy_association" "eks_access_policy" {
  cluster_name  = "${var.project}-${var.environment}-eks-cluster"
  policy_arn    = var.policy_arn
  principal_arn = var.principal_arn == null ? local.default_principal_arn : var.principal_arn

  access_scope {
    type = var.access_scope_type
  }
}
