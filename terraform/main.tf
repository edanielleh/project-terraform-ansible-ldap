variable "gce_ssh_user" {} 
variable "gcloud_compute_project_name" {} 
variable "gce_ssh_pub_key_file" {} 
variable "region" {} 
variable "machine_type" {} 
variable "network_resource_name" {} 
variable "firewall_resource_name" {} 
variable "disk_resource_name" {} 

provider "google" {
  region = "${var.region}"
}

resource "random_id" "instance_id" {
  byte_length = 8
}

resource "google_compute_instance" "default" {
  name         = "vm-${random_id.instance_id.hex}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region}"
  project      = "${var.gcloud_compute_project_name}"
  
#runs on local once instance is running
  provisioner "local-exec" "default" {
    command = "echo ${google_compute_instance.default.network_interface.0.access_config.0.nat_ip} > ../ansible/hosts"
  }

#runs on instance once running
  metadata_startup_script = "mkdir /ldap"

  network_interface {
    network = "default"

    access_config {
      // Include this section to give the VM an external ip address
    }
  }

  boot_disk {
    initialize_params {
      image = "centos-cloud/centos-7"
    }
  }

}

resource "google_compute_disk" "default" {
  name  = "${var.disk_resource_name}"
  zone  = "${var.region}"
  project = "${var.gcloud_compute_project_name}"
}

resource "google_compute_firewall" "default" {
  name    = "${var.firewall_resource_name}"
  network = "${google_compute_network.default.name}"
  project = "${var.gcloud_compute_project_name}"
  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
}

resource "google_compute_network" "default" {
  name    = "${var.network_resource_name}"
  project = "${var.gcloud_compute_project_name}"
}

output "ip" {
  value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}

resource "google_compute_project_metadata" "default" {
  project = "${var.gcloud_compute_project_name}"
  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }
}
