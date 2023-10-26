############ Cloud Storage ############
resource "google_storage_bucket" "static" {
  name          = "gcp-se-test-amie-bucket"
  location      = "US"
  storage_class = "STANDARD"

  uniform_bucket_level_access = true
}

# Upload an image file as an object to the storage bucket
resource "google_storage_bucket_object" "image" {
  name         = "test-obj"
  source       = "./asset/bison.png"
  content_type = "image/png"
  bucket       = google_storage_bucket.static.id
}

#################### GCE ##################
data "google_compute_image" "debian_image" {
  family  = "debian-11"
  project = "debian-cloud"
}

data "google_compute_default_service_account" "default" {
}

resource "google_compute_address" "static" {
  name = "ipv4-address"
}

resource "google_compute_instance" "instance_with_ip" {
  name                      = "vm-instance"
  machine_type              = "e2-micro"
  zone                      = var.zone
  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = data.google_compute_image.debian_image.self_link
    }
  }

  network_interface {
    network = "default"
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  metadata_startup_script = <<-EOT
    apt update && apt install -y python3
    mkdir /home/image_dir
    gsutil cp gs://${google_storage_bucket.static.name}/${google_storage_bucket_object.image.name} /home/image_dir/
    cd /home/image_dir/
    echo '<html>
            <head>
            <style>
                img.responsive {
                    max-width: 500px;
                    max-height: 1000px;
                    width: auto;
                    height: auto;
                }
            </style>
            </head>
            <body>
                <img src="${google_storage_bucket_object.image.name}" alt="Image" class="responsive">
            </body>
            </html>' > index.html
    nohup python3 -m http.server 80 &
    EOT

  labels = {
    env = "dev"
  }

  tags = ["http-server"]

  # assign service account to allow gce access to bucket
  service_account {
    email  = data.google_compute_default_service_account.default.email
    scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }


}

# Allow HTTP traffic
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server"]
}

