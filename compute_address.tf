resource "google_compute_address" "kubernetes_the_hard_way" {
  name = "kubernetes-public-api-server"

  region = "europe-west3"
}
