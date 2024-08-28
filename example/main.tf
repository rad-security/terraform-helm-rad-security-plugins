provider "rad-security" {
  access_key_id = "YOUR_ACCESS_KEY_HERE"
  secret_key    = "YOUR_SECRET_KEY_HERE"
}

provider "helm" {

}


module "rad_install" {
  source = "../"
  # version = "1.0.0"

  install_cert_manager = true

  cluster_name = "Example Cluster"

  helm_settings = [{
    name  = "ksocSync.resources.limits.cpu"
    value = "500m"
    type  = "string"
  }]

  plugin_configuration_file = ["${file("./values.yaml")}"]
}
