resource "google_compute_network" "vpc_network" {
  project                 = "${google_project.samatar_dev.project_id}"
  name                    = "kubernetes-the-hard-way"
  auto_create_subnetworks = false # We want to create a custom network so we can set a large enough IP address range, to assign a private IP address to each node in the Kubernetes cluster.
}

resource "google_compute_subnetwork" "kubernetes-the-hard-way-subnet" {
  name          = "kubernetes-cluster-subnet"
  network       = google_compute_network.vpc_network.id
  ip_cidr_range = "10.240.0.0/24" # allows us to host up to 254 compute instances
}

resource "google_compute_firewall" "allow-internal" {
  name    = "kubernetes-the-hard-way-allow-internal"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"

  }

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "udp"
  }

  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"] #question what is 10.200.0.0/16?
}
