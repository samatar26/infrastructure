resource "google_cloud_run_service" "anime-api" {
  name     = "anime"
  location = "europe-west3"

  template {
    spec {
      containers {
        image = "eu.gcr.io/samatar-dev-43f2d25b/anime-api"
      }

      service_account_name = google_service_account.anime_api_cloud_run.email
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.instance.anime
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}
