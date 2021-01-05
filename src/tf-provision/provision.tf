variable "project" {}
variable "folder_id" {}
variable "billing_account" {}

locals {
  region = "us-central1"
  zone   = "us-central1-b"
}

provider "google-beta" {
  region = local.region
  zone   = local.zone
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.project}-"
}



resource "google_project" "root_project" {
  name       = random_id.id.hex
  project_id = random_id.id.hex
  folder_id  = var.folder_id
  billing_account = var.billing_account
}

resource "google_project_service" "crmservice" {
  project = google_project.root_project.project_id
  service = "cloudresourcemanager.googleapis.com"

  disable_dependent_services = true
}

resource "google_project_service" "containerservice" {
  project = google_project.root_project.project_id
  service = "container.googleapis.com"

  disable_dependent_services = true

  depends_on = [
    google_project_service.crmservice
  ]
}

resource "google_container_cluster" "primary" {
  name      = "cluster-1"
  project   = google_project.root_project.project_id
  location  = local.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count = 1

  master_auth {
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }
  depends_on = [
    google_project_service.containerservice
  ]
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = "primary-node-pool"
  project    = google_project.root_project.project_id
  cluster    = google_container_cluster.primary.name
  location   = local.zone
  node_count = 1

  node_config {
    preemptible  = true
    machine_type = "e2-medium"

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}