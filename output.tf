output "namespace" {
  value       = module.kong_mesh_helm.namespace
  description = "Namespace in which kong is being created"
}
