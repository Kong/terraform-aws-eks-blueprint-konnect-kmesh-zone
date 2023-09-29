data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "kubernetes_secret" "external_secrets" {
  metadata {
    name      = "sh.helm.release.v1.external-secrets.v1"
    namespace = "external-secrets"
  }
}

resource "time_sleep" "this" {
  create_duration = var.create_delay_duration
  triggers = {
    cluster_endpoint  = var.cluster_endpoint
    cluster_name      = var.cluster_name
    custom            = join(",", var.create_delay_dependencies)
    oidc_provider_arn = var.oidc_provider_arn
  }
}
data "aws_kms_alias" "secret_manager" {
  name = "alias/aws/secretsmanager"
}


data "aws_iam_policy_document" "kong_external_secret_secretstore" {
  statement {
    sid = "1"

    actions = [
      "secretsmanager:GetResourcePolicy",
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret",
      "secretsmanager:ListSecretVersionIds"
    ]
    resources = [
      "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:${local.cp_token_aws_secret_name}-*",
    ]
  }
  statement {
    actions = [
      "kms:Decrypt"
    ]

    resources = [
      data.aws_kms_alias.secret_manager.arn
    ]
  }
}
