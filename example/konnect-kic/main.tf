data "aws_eks_cluster" "eks" {
  name = var.eks_cluster_name
}

data "aws_caller_identity" "current" {}

locals {
  name = "konnect-kic"

  tags = {
    Kong_Blueprint = "KIC Konnect"
  }

  telemetry_dns = replace(var.telemetry_endpoint, "https://", "")

  apiHostname = "${var.konnect_region}.kic.api.konghq.com"

  eks_oidc_issuer   = trimprefix(data.aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://")
  oidc_provider_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${local.eks_oidc_issuer}"
}

module "eks-blueprint-konnect-kic" {

  source = "/Users/daniella.freese@konghq.com/Projects/Kong/eks_blueprints/terraform-aws-eks-blueprint-konnect-kic"
  # version = "~> 1.0.1"

  cluster_name      = var.eks_cluster_name
  cluster_endpoint  = data.aws_eks_cluster.eks.endpoint
  cluster_version   = data.aws_eks_cluster.eks.version
  oidc_provider_arn = local.oidc_provider_arn

  tags = local.tags

  kong_config = {
    # chart_version    = "0.3.0"
    runtimeGroupID   = var.runtimeGroupID
    apiHostname      = local.apiHostname
    telemetry_dns    = local.telemetry_dns
    cert_secret_name = var.cert_secret_name
    key_secret_name  = var.key_secret_name

    add_ons = {
      enable_external_secrets = false
    }
  }
}
