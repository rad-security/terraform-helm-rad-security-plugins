# terraform-helm-rad-security-plugins
A terraform module for installing Rad Security Plugins through Terraform.

## Description

This module provides a flexible way to deploy Rad Security plugins using Helm. It allows you to configure various components of the Rad Security suite, including Guard, SBOM, Sync, Watch, Node Agent, and K9.

Rad Security currently requires Cert Manager to be installed prior to installing the plugins. This can be disabled by setting `install_cert_manager` to `false`.

## Features

- Automatic cluster API key generation
- Optional installation of cert-manager
- Installs Rad Security plugins using Helm
- Configurable components of the Rad Security plugins (Guard, SBOM, Sync, Watch, Node Agent, K9)

## Usage
To use this module, two providers are required. The `rad-security` provider and the `helm` provider.

To configure the `rad-security` provider, the cloud api keys must be provided.

```hcl
provider "rad-security" {
  access_key_id        = "YOUR_ACCESS_KEY_ID"
  secret_key           = "YOUR_SECRET_KEY"
}
```

The second provider is the `helm` provider. This provider requires a kubernetes configuration. This can be provided in multiple ways. Here are two examples of configuring the helm provider.

1. By using the `config_path` attribute to point to a local kubeconfig file.
2. By providing the kubernetes host, token, and cluster_ca_certificate.

### Local Kubeconfig
```hcl
provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}
```

### AWS EKS
```hcl
provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.eks_cluster_endpoint
    token                  = data.aws_eks_cluster_auth.kubernetes.token
    cluster_ca_certificate = base64decode(module.eks_cluster.eks_cluster_certificate_authority_data)
  }
}
```

## Additional Usecases

The namespace and service account name for SBOM is exported as outputs. This allows for easy integration with IRSA or EKS Pod Identity.

EKS Pod Identity:

```hcl
resource "aws_eks_pod_identity_association" "rad_sbom" {
  cluster_name    = aws_eks_cluster.example.name
  namespace       = module.rad_plugin.rad_plugin_namespace
  service_account = module.rad_plugin.sbom_service_account_name
  role_arn        = aws_iam_role.example.arn
}

IRSA:
```hcl

module "iam_assumable_role_example" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.6.0"
  create_role                   = true
  role_name                     = local.example_role_name
  provider_url                  = replace(module.eks.cluster_oidc_issuer_url, "https://", "")
  role_policy_arns              = [aws_iam_policy.cluster_autoscaler.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:${module.rad_plugin.rad_plugin_namespace}:${module.rad_plugin.sbom_service_account_name}"]
}


module "rad_install" {
  source = "../"
  # version = "1.0.0"

  install_cert_manager = true

  cluster_name = "Example"

  helm_settings = [{
    name = "ksocSbom.serviceAccount.annotations.eks.amazonaws.com/role-arn"
    value = module.iam_assumable_role_example.iam_role_arn
    type = "string"
  }]

  plugin_configuration_file = ["${file("./values.yaml")}"]
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_helm"></a> [helm](#provider\_helm) | n/a |
| <a name="provider_rad-security"></a> [rad-security](#provider\_rad-security) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [helm_release.cert-manager](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.plugins](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [rad-security_cluster_api_key.this](https://registry.terraform.io/providers/hashicorp/rad-security/latest/docs/resources/cluster_api_key) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster Name to use within the Rad Platform | `string` | `""` | no |
| <a name="input_enable_guard"></a> [enable\_guard](#input\_enable\_guard) | Toggles the Guard component | `bool` | `true` | no |
| <a name="input_enable_k9"></a> [enable\_k9](#input\_enable\_k9) | Toggles the K9 component | `bool` | `false` | no |
| <a name="input_enable_node_agent"></a> [enable\_node\_agent](#input\_enable\_node\_agent) | Toggles the Node Agent component | `bool` | `false` | no |
| <a name="input_enable_openshift"></a> [enable\_openshift](#input\_enable\_openshift) | Toggles support for OpenShift | `bool` | `false` | no |
| <a name="input_enable_sbom"></a> [enable\_sbom](#input\_enable\_sbom) | Toggles the SBOM component | `bool` | `true` | no |
| <a name="input_enable_sync"></a> [enable\_sync](#input\_enable\_sync) | Toggles the Sync component | `bool` | `true` | no |
| <a name="input_enable_watch"></a> [enable\_watch](#input\_enable\_watch) | Toggles the Watch component | `bool` | `true` | no |
| <a name="input_helm_settings"></a> [helm\_settings](#input\_helm\_settings) | List of Helm configuration values to set | <pre>list(object({<br>    name  = string<br>    value = string<br>    type  = string<br>    }<br>  ))</pre> | `[]` | no |
| <a name="input_install_cert_manager"></a> [install\_cert\_manager](#input\_install\_cert\_manager) | Set to toggle the installation of cert-manager before the installation of plugins | `bool` | `true` | no |
| <a name="input_plugin_configuration_file"></a> [plugin\_configuration\_file](#input\_plugin\_configuration\_file) | Location of the values.yaml file to use with rad plugins | `list(string)` | `[]` | no |
| <a name="input_rad_plugin_namespace"></a> [rad\_plugin\_namespace](#input\_rad\_plugin\_namespace) | Namespace to install the Rad Platform plugins into | `string` | `"ksoc"` | no |
| <a name="input_rad_plugin_version"></a> [rad\_plugin\_version](#input\_rad\_plugin\_version) | Helm chart version to use | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rad_plugin_namespace"></a> [rad\_plugin\_namespace](#output\_rad\_plugin\_namespace) | n/a |
| <a name="output_sbom_service_account_name"></a> [sbom\_service\_account\_name](#output\_sbom\_service\_account\_name) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
