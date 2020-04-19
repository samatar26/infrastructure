resource "google_storage_bucket" "terraform_state" {
  name = "samatar-tf-state"

  project = "${google_project.samatar_dev.project_id}"

  location = "EU"
  versioning {
    enabled = true
  }

}

resource "google_storage_bucket" "www_anime_samatar_dev" {
  name = "anime.samatar.dev"

  project = "${google_project.samatar_dev.project_id}"

  location = "EU"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

}
