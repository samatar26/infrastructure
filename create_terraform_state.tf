provider "google" {
  project = "proud-apogee-261010"
}

resource "google_storage_bucket" "terraform_state" {
  name = "samatar-tf-state"

  versioning {
    enabled = true
  }

}
