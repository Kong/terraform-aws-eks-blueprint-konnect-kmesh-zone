
data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

data "aws_caller_identity" "current" {}

locals {
  name = basename(path.cwd)

  tags = {
    Kong_Blueprint = "Kong Mesh in Konnect"
  }

  konnect_kds_global_address = "grpcs://${var.konnect_region}.mesh.sync.konghq.com:443"
  eks_oidc_issuer            = trimprefix(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://")
  oidc_provider_arn          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer}"
}

module "eks-blueprint-konnect-mink" {
  source = "../"
  # version = "1.0.1"

  cluster_name      = var.eks_cluster_name
  cluster_endpoint  = data.aws_eks_cluster.eks.endpoint
  cluster_version   = data.aws_eks_cluster.eks.version
  oidc_provider_arn = local.oidc_provider_arn

  tags = local.tags

  kong_config = {
    zone                                   = var.zone_name
    cpId                                   = var.konnect_mesh_global_cp_id
    kdsGlobalAddress                       = local.konnect_kds_global_address
    kmesh_ingress_enabled                  = true
    kmesh_egress_enabled                   = true
    kmesh_k8sServices_experimental_enabled = true
    cp_token_aws_secret_name               = var.cp_token_aws_secret_name
    add_ons = {
      enable_external_secret_store = true
    }
  }
}


