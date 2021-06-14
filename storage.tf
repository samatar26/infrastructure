resource "google_storage_bucket" "terraform_state" {
  name = "samatar-tf-state"

  location = "US-EAST1" # Free

  versioning {
    enabled = true
  }

}

resource "google_storage_bucket" "marhaban" {
  name = "marhaban.samatar.dev"

  location = "US-EAST1"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  lifecycle {
    prevent_destroy = true
  }

}

resource "google_storage_bucket" "samatar_pachama" {
  name = "pachama.samatar.dev"

  location = "US-EAST1"

  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  lifecycle {
    prevent_destroy = true
  }

}
