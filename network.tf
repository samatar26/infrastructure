resource "google_compute_network" "vpc_network" {
  name                    = "kubernetes-the-hard-way"
  auto_create_subnetworks = false
}
