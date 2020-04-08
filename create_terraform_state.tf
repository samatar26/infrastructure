provider "google" {
  project = "fluent-crossbar-261008"
}

resource "google_storage_bucket" "terraform_state" {
  name = "samatar-tf-state"

  versioning {
    enabled = true
  }

}
