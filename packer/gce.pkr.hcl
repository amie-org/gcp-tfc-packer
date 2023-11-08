packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}


# only the source config will be inherited by the children, not the build configs
source "googlecompute" "test-image" {
  project_id          = var.project_id
  source_image_family = "ubuntu-2204-lts"
  zone                = var.zone
  image_description   = "Created with HashiCorp Packer"
  ssh_username        = "root"
  tags                = ["packer", "ubuntu"]
}

build {
  hcp_packer_registry {
    bucket_name = "packer-gce-ubuntu"
    description = "Ubuntu Image for GCE Built By Packer"

    # these are labels on HCP Packer, not on the image
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

  # install vault
  provisioner "shell" {
    script = "./vault.sh"
  }

  # generates a packer_manifest.json file containing the packer.iterationID
  # The GitHub Action retrieves the iteration ID from this file and updates the respective channel to reference it. 
  post-processor "manifest" {
    output     = "packer_manifest.json"
    strip_path = true
    custom_data = {
      iteration_id = packer.iterationID
    }
  }

}