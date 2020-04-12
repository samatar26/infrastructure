resource "google_service_account" "terraform" {
  project      = "${google_project.samatar_dev.project_id}"
  account_id   = "terraform"
  display_name = "Terraform SA"
}

resource "google_service_account" "circle_deploy" {
  project      = "${google_project.samatar_dev.project_id}"
  account_id   = "circleci_deploy"
  display_name = "CircleCI Deploy"
}

resource "google_project_iam_member" "terraform_owner" {
  project = "${google_project.samatar_dev.project_id}"
  role    = "roles/owner"
  member  = "serviceAccount:${google_service_account.terraform.email}"
}


resource "google_project_iam_member" "circleci_deploy" {
  project = "${google_project.samatar_dev.project_id}"
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.circleci_deploy.email}"
}
