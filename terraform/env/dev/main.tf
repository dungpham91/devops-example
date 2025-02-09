module "vpc" {
  source               = "../../modules/vpc"
  aws_region           = var.aws_region
  default_tags         = var.default_tags
  project              = var.project
  environment          = var.environment
  private_subnets_cidr = var.private_subnets_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  vpc_cidr             = var.vpc_cidr
}

module "kms" {
  source       = "../../modules/kms"
  default_tags = var.default_tags
  project      = var.project
  environment  = var.environment
}

module "eks" {
  source                      = "../../modules/eks"
  default_tags                = var.default_tags
  project                     = var.project
  environment                 = var.environment
  vpc_id                      = module.vpc.vpc_id
  vpc_cidr                    = [module.vpc.cidr_block]
  private_subnets             = module.vpc.aws_subnets_private
  public_subnets              = module.vpc.aws_subnets_public
  eks_cluster_version         = var.eks_cluster_version
  kms_key_arn                 = module.kms.kms_arn
  custom_ami_id               = var.custom_ami_id
  node_group_name             = var.node_group_name
  node_capacity_type          = var.node_capacity_type
  node_instance_type          = var.node_instance_type
  node_group_desired_capacity = var.node_group_desired_capacity
  node_group_min_size         = var.node_group_min_size
  node_group_max_size         = var.node_group_max_size

  depends_on = [
    module.vpc,
    module.kms
  ]
}

module "eks_access" {
  source            = "../../modules/eks-access"
  project           = var.project
  environment       = var.environment
  access_entry_type = var.access_entry_type
  access_scope_type = var.access_scope_type
  kubernetes_groups = var.kubernetes_groups
  policy_arn        = var.policy_arn
  principal_arn     = var.principal_arn

  depends_on = [module.eks]
}
