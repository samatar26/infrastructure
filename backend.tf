terraform {
  backend "gcs" {
    bucket = "samatar-tf-state"
  }

  required_providers {
    cloudflare = {
      source  = "registry.terraform.io/cloudflare/cloudflare"
      version = "2.18.0"
    }
  }
}
