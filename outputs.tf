output "rad_plugin_namespace" {
  value = helm_release.plugins.namespace
}

output "sbom_service_account_name" {
  value = "ksoc-sbom"
}
