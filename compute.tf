resource "google_compute_address" "kubernetes_the_hard_way" {
  name = "kubernetes-public-api-server"

  region = "europe-west3"
}


# Create 3 compute instances for the control plane
resource "google_compute_instance" "controller" {
  count = 3

  can_ip_forward = true
  name           = "kubernetes-controller-${count.index}"
  zone           = "europe-west3-a"

  boot_disk {
    initialize_params {
      size  = 200
      image = "ubuntu-2004-lts"

    }
  }

  network_interface {
    subnetwork = "kubernetes-cluster-subnet"
    network_ip = "10.240.0.1${count.index}"
  }



  machine_type = "e2-standard-2"
  tags         = ["kubernetes-the-hard-way", "controller"]

  #Question haven't defined scopes, will need to see if needed later on:
  # compute-rw,storage-ro,service-management,service-control,logging-write,monitoring
}


# 3 compute instances to host the Kubernetes worker nodes
resource "google_compute_instance" "worker" {
  count = 3

  name = "kubernetes-worker-${count.index}"


  boot_disk {
    initialize_params {
      size  = 200
      image = "ubuntu-2004-lts"
    }
  }

  network_interface {
    subnetwork = "kubernetes-cluster-subnet"
    network_ip = "10.240.0.2${count.index}"
  }

  metadata = {
    "pod-cidr" = "10.200.${count.index}.0/24" # pod subnet allocation will used to configure container networking at a later stage
  }

  machine_type = "e2-standard-2"
  tags         = ["kubernetes-the-hard-way", "worker"]
}
