terraform {
  cloud {
    organization = "tf-se-test"

    workspaces {
      name = "gce-display-image-using-packer"
    }
  }
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.3.0"
    }
    hcp = {
      source  = "hashicorp/hcp"
      version = "0.75.0"
    }
  }
}

provider "google" {
  # Configuration options
  region = var.region
  zone   = var.zone
}
