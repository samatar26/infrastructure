resource "google_cloud_run_service" "forests" {
  name     = "forests"
  location = "europe-west3"

  template {
    spec {
      containers {
        image = "eu.gcr.io/${google_project.samatar_dev.project_id}/forests"
        ports {
          container_port = 8000
        }
      }

      service_account_name = google_service_account.forests_cloud_run.email
    }

    metadata {
      annotations = {
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.forests.connection_name
      }
    }

  }

  traffic {
    percent         = 100
    latest_revision = true
  }

}
