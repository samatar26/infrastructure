terraform {
  backend "gcs" {
    bucket = "samatar-tf-state"
  }
}

