packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}


source "googlecompute" "test-image" {
  project_id          = var.project_id
  source_image_family = "ubuntu-2204-lts"
  zone                = var.zone
  image_description   = "Created with HashiCorp Packer"
  ssh_username        = "root"
  tags                = ["packer"]
}

build {
  hcp_packer_registry {
    bucket_name = "packer-gce-ubuntu"
    description = "Ubuntu Image for GCE Built By Packer"

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
  sources = ["sources.googlecompute.test-image"]

}