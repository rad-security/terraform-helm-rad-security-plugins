terraform {
  required_providers {
    rad-security = {
      source = "rad-security/rad-security"
    }
    helm = {
      source = "hashicorp/helm"
    }
  }
}

resource "rad-security_cluster_api_key" "this" {}

resource "helm_release" "cert-manager" {
  count      = var.install_cert_manager ? 1 : 0
  name       = "certmanager"
  repository = "https://charts.jetstack.io"

  chart   = "cert-manager"
  version = "v1.15.0"

  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "enableCertificateOwnerRef"
    value = "true"
  }

}

resource "helm_release" "plugins" {
  name       = "ksoc"
  repository = "https://charts.ksoc.com/stable"
  chart      = "ksoc-plugins"
  version    = var.rad_plugin_version != "" ? var.rad_plugin_version : null

  namespace        = var.rad_plugin_namespace
  create_namespace = true

  values = var.plugin_configuration_file

  set_sensitive {
    name  = "ksoc.base64AccessKeyId"
    value = base64encode(rad-security_cluster_api_key.this.access_key)
  }

  set_sensitive {
    name  = "ksoc.base64SecretKey"
    value = base64encode(rad-security_cluster_api_key.this.secret_key)
  }

  set {
    name  = "ksoc.clusterName"
    value = local.cluster_name
  }

  set {
    name  = "ksocGuard.enable"
    value = var.enable_guard
  }

  set {
    name  = "ksocSbom.enable"
    value = var.enable_sbom
  }

  set {
    name  = "ksocSync.enable"
    value = var.enable_sync
  }

  set {
    name  = "ksocWatch.enable"
    value = var.enable_watch
  }


  dynamic "set" {
    for_each = var.enable_node_agent ? [1] : []

    content {
      name  = "ksocNodeAgent.enable"
      value = true
      type  = "bool"
    }
  }

  dynamic "set" {
    for_each = var.enable_k9 ? [1] : []

    content {
      name  = "k9.enable"
      value = true
      type  = "bool"
    }
  }

  dynamic "set" {
    for_each = var.enable_openshift ? [1] : []

    content {
      name  = "openshift.enable"
      value = true
      type  = "bool"
    }
  }

  dynamic "set" {
    for_each = var.helm_settings
    content {
      name  = set.value.name
      value = set.value.value
      type  = set.value.type
    }
  }

  # This value does not do anything to the plugin helm chart.
  # It creates an implict dependency on cert-manager if it is installed.
  dynamic "set" {
    for_each = var.install_cert_manager ? [1] : []

    content {
      name  = "cert_manager_installed"
      value = helm_release.cert-manager[0].name
    }
  }
}
