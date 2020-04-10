variable "billing_account" {}

locals {
  project_name = "samatar-dev"
}

resource "random_id" "project_id" {
  byte_length = 4
  prefix      = "${local.project_name}-"
}

resource "google_project" "samatar_dev" {
  name       = local.project_name
  project_id = random_id.project_id.hex

  billing_account = "${var.billing_account}"
}
