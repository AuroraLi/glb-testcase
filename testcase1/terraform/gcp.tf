provider "google" {
#  credentials = file(local.credentials_file_path)
  version     = "~> 3.3.0"
}

provider "google-beta" {
#  credentials = file(local.credentials_file_path)
  version     = "~> 3.3.0"
}

provider "null" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

data "google_project" "gke_project" {
  project_id = var.gke_project_id
}

