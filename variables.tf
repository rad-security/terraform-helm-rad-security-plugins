variable "cluster_name" {
  description = "Cluster Name to use within the Rad Platform"
  type        = string
  default     = ""
}

variable "enable_guard" {
  description = "Toggles the Guard component"
  type        = bool
  default     = true
}

variable "enable_sbom" {
  description = "Toggles the SBOM component"
  type        = bool
  default     = true
}

variable "enable_sync" {
  description = "Toggles the Sync component"
  type        = bool
  default     = true
}

variable "enable_watch" {
  description = "Toggles the Watch component"
  type        = bool
  default     = true
}

variable "enable_node_agent" {
  description = "Toggles the Node Agent component"
  type        = bool
  default     = false
}

variable "enable_k9" {
  description = "Toggles the K9 component"
  type        = bool
  default     = false
}

variable "enable_openshift" {
  description = "Toggles support for OpenShift"
  type        = bool
  default     = false
}

variable "helm_settings" {
  description = "List of Helm configuration values to set"
  type = list(object({
    name  = string
    value = string
    type  = string
    }
  ))
  default = []
}

variable "install_cert_manager" {
  description = "Set to toggle the installation of cert-manager before the installation of plugins"
  type        = bool
  default     = true
}

variable "rad_plugin_namespace" {
  description = "Namespace to install the Rad Platform plugins into"
  type        = string
  default     = "ksoc"
}

variable "plugin_configuration_file" {
  description = "Location of the values.yaml file to use with rad plugins"
  type        = list(string)
  default     = []
}

variable "rad_plugin_version" {
  description = "Helm chart version to use"
  type        = string
  default     = ""
}
