resource "google_storage_bucket" "terraform_state" {
  name = "samatar-tf-state"

  project = "${google_project.samatar_dev.project_id}"

  location = "EU"
  versioning {
    enabled = true
  }

}

resource "google_storage_bucket" "www.anime.samatar.dev" {
  name = "www.anime.samatar.dev"

  project = "${google_project.samatar_dev.project_id}"

  location = "EU"
}
