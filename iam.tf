resource "google_service_account" "terraform" {
  account_id   = "terraform"
  display_name = "Terraform SA"
}

resource "google_service_account" "circleci_deploy" {
  account_id   = "circleci-deploy"
  display_name = "CircleCI Deploy SA"
}

resource "google_service_account" "anime_api_cloud_run" {
  account_id   = "anime-api"
  display_name = "Cloud run anime api SA"
}

resource "google_project_iam_member" "terraform_owner" {
  role   = "roles/owner"
  member = "serviceAccount:${google_service_account.terraform.email}"
}


resource "google_project_iam_member" "circleci_deploy_registry" {
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.circleci_deploy.email}"
}


resource "google_project_iam_member" "cloud_sql_client" {
  role   = "roles/cloudsql.client"
  member = "serviceAccount:${google_service_account.anime_api_cloud_run.email}"
}
