locals {

  # Threads the sleep resource into the module to make the dependency
  cluster_endpoint  = time_sleep.this.triggers["cluster_endpoint"]
  cluster_name      = time_sleep.this.triggers["cluster_name"]
  oidc_provider_arn = time_sleep.this.triggers["oidc_provider_arn"]

  # https://kong.github.io/kong-mesh-charts
  name             = try(var.kong_config.name, "kong-mesh")
  namespace        = try(var.kong_config.namespace, "kong-mesh-system")
  create_namespace = try(var.kong_config.create_namespace, true)
  chart            = "kong-mesh"
  chart_version    = try(var.kong_config.chart_version, null)
  repository       = try(var.kong_config.repository, "https://kong.github.io/kong-mesh-charts")
  values           = try(var.kong_config.values, [])

  zone                     = try(var.kong_config.zone, null)
  cpId                     = try(var.kong_config.cpId, null)
  kdsGlobalAddress         = try(var.kong_config.konnect_kds_global_address, "grpcs://us.mesh.sync.konghq.com:443")
  ingress_enabled          = try(var.kong_config.kmesh_ingress_enabled, true)
  egress_enabled           = try(var.kong_config.kmesh_egress_enabled, true)
  deltaKds_enabled         = try(var.kong_config.deltaKds_enabled, true)
  cp_token_aws_secret_name = try(var.kong_config.cp_token_aws_secret_name, null)

  enable_external_secrets = try(var.kong_config.add_ons.enable_external_secrets, true)

  external_secret_service_account_name                = "external-secret-irsa"
  external_secrets_irsa_role_name                     = "external-secret-irsa-konnect-kmesh"
  external_secrets_irsa_role_name_use_prefix          = true
  external_secrets_irsa_role_path                     = "/"
  external_secrets_irsa_role_permissions_boundary_arn = null
  external_secrets_irsa_role_description              = "IRSA for external-secrets operator"
  external_secrets_irsa_role_policies                 = {}


  set_values = [
    {
      name  = "kuma.controlPlane.mode"
      value = "zone"
    },
    {
      name  = "kuma.controlPlane.zone"
      value = local.zone
    },
    {
      name  = "kuma.controlPlane.kdsGlobalAddress"
      value = local.kdsGlobalAddress
    },
    {
      name  = "kuma.controlPlane.konnect.cpId"
      value = local.cpId
    },
    {
      name  = "kuma.controlPlane.secrets[0].Env"
      value = "KMESH_MULTIZONE_ZONE_KDS_AUTH_CP_TOKEN_INLINE"
    },
    {
      name  = "kuma.controlPlane.secrets[0].Secret"
      value = "cp-token"
    },
    {
      name  = "kuma.controlPlane.secrets[0].Key"
      value = "token"
    },
    {
      name  = "kuma.ingress.enabled"
      value = local.ingress_enabled
    },
    {
      name  = "kuma.egress.enabled"
      value = local.egress_enabled
    },
    {
      name  = "kuma.experimental.deltaKds"
      value = local.deltaKds_enabled
    }
  ]
}
