resource "google_storage_bucket" "terraform_state" {
  name = "samatar-tf-state"

  project = "${google_project.samatar_dev.project_id}"

  location = "EU"
  versioning {
    enabled = true
  }

}
