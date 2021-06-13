resource "google_sql_database_instance" "anime" {

  name             = "anime"
  database_version = "POSTGRES_12"
  region           = "europe-west2"

  settings {
    tier = "db-custom-1-3840"
  }

}

resource "google_sql_database" "anime" {
  name     = "anime"
  instance = google_sql_database_instance.anime.name
}

variable "anime_db_password" {}

resource "google_sql_user" "anime" {
  name     = "anime"
  instance = google_sql_database_instance.anime.name
  password = var.anime_db_password
}
