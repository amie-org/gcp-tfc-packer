terraform {
  cloud {
    organization = "tf-se-test"

    workspaces {
      name = "gce-display-image"
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.3.0"
    }
  }
}

provider "google" {
  # Configuration options
  region = var.region
  zone   = var.zone
}
