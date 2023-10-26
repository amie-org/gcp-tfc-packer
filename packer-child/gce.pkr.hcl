packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

data "hcp-packer-image" "packer-gce-ubuntu" {
  bucket_name    = "packer-gce-ubuntu"
  channel        = "latest"
  cloud_provider = "gce"
  region         = "us-central1-c"
}

# Needs an individual source for building an image for each region (packer will create 2 temp vm for creating the images)
source "googlecompute" "child-image-zone-a" {
  project_id        = var.project_id
  source_image      = data.hcp-packer-image.packer-gce-ubuntu.id # This assumes the name/family of the parent image you built is "packer-gce-ubuntu"
  zone              = var.zones[0]
  image_description = "Child image based on base Ubuntu image"
  ssh_username      = "root"
  image_name        = "packer-${var.zones[0]}-{{timestamp}}"
  tags              = ["packer", "child-image"]
}

source "googlecompute" "child-image-zone-b" {
  project_id        = var.project_id
  source_image      = data.hcp-packer-image.packer-gce-ubuntu.id # This assumes the name/family of the parent image you built is "packer-gce-ubuntu"
  zone              = var.zones[1]
  image_description = "Child image based on base Ubuntu image"
  ssh_username      = "root"
  image_name        = "packer-${var.zones[1]}-{{timestamp}}"
  tags              = ["packer", "child-image"]
}

build {
  hcp_packer_registry {
    bucket_name = "packer-gce-ubuntu-child"
    description = "Child Ubuntu Image for GCE Built By Packer"

    bucket_labels = {
      "owner"          = "platform-team"
      "os"             = "Ubuntu",
      "ubuntu-version" = "ubuntu-2204-lts",
    }

    build_labels = {
      "build-time"   = timestamp()
      "build-source" = basename(path.cwd)
    }
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx",
      "echo 'hello world' | sudo tee /var/www/html/index.html"
    ]
  }

  sources = ["sources.googlecompute.child-image-zone-a", "sources.googlecompute.child-image-zone-b"]
}
