data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

data "aws_caller_identity" "current" {}

locals {
  name = "konnect-kong-runtimeinstance"

  tags = {
    Kong_Blueprint = "Kong Gateway - Konnect"
  }

  telemetry_dns = replace(var.telemetry_endpoint, "https://", "")
  cluster_dns   = replace(var.cluster_endpoint, "https://", "")

  eks_oidc_issuer            = trimprefix(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://")
  oidc_provider_arn          = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer}"
}

module "eks-blueprint-konnect-runtimeinstance" {
  
  source = "github.com/Kong/terraform-aws-eks-blueprint-konnect-runtime-instance?ref=enable_external_secrets"

  cluster_name      = var.eks_cluster_name
  cluster_endpoint  = data.aws_eks_cluster.eks.endpoint
  cluster_version   = data.aws_eks_cluster.eks.version
  oidc_provider_arn = local.oidc_provider_arn

  tags                    = local.tags

  kong_config = {
    cluster_dns      = local.cluster_dns
    telemetry_dns    = local.telemetry_dns
    cert_secret_name = var.cert_secret_name
    key_secret_name  = var.key_secret_name

    add_ons = {
      enable_external_secrets = false
    }
  }
}