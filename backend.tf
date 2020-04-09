terraform {
  backend "gcs" {
    bucket = "samatar-terraform-state"
  }
}
