resource "google_compute_network" "vpc_network" {
  project                 = "${google_project.samatar_dev.project_id}"
  name                    = "kubernetes-the-hard-way"
  auto_create_subnetworks = false
}
