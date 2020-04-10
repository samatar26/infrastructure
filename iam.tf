resource "google_service_account" "terraform" {
  project      = "${google_project.samatar_dev.project_id}"
  account_id   = "terraform"
  display_name = "Terraform SA"
}

resource "google_project_iam_member" "terraform_owner" {
  project = "${google_project.samatar_dev.project_id}"
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}

