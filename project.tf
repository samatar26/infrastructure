provider "google" {
  alias = "seed"
}

provider "google" {
  project = google_project.samatar_dev.project_id

}

provider "google" {
  alias  = "europe-west-2"
  region = "europe-west2-c"
  zone   = "europe-west2"
}

variable "billing_account" {}

locals {
  project_name = "samatar-dev"
}

resource "random_id" "project_id" {
  byte_length = 4
  prefix      = "${local.project_name}-"
}

resource "google_project" "samatar_dev" {
  provider = google.seed

  name       = local.project_name
  project_id = random_id.project_id.hex

  billing_account = var.billing_account
}

resource "google_project_service" "s" {
  project = google_project.samatar_dev.project_id

  service = each.key

  for_each = {
    for i in [
      "cloudresourcemanager.googleapis.com",
      "cloudbilling.googleapis.com",
      "iam.googleapis.com",
      "serviceusage.googleapis.com",
      "storage-api.googleapis.com",
      "containerregistry.googleapis.com",
      "compute.googleapis.com"
    ] : i => i
  }

}
