resource "google_storage_bucket" "terraform_state" {
  name = "samatar-tf-state"

  location = "EU"

  versioning {
    enabled = true
  }

}

resource "google_storage_bucket" "design" {
  name = "design.samatar.dev"

  location = "EU"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  lifecycle {
    prevent_destroy = true
  }

}
