output "vm_external_ip_addr" {
  value = "http://${google_compute_instance.instance_with_ip.network_interface[0].access_config[0].nat_ip}"
}

output "gsutil_uri" {
  value = "gs://${google_storage_bucket.static.name}/${google_storage_bucket_object.image.name}"
}

output "default_gce_service_account" {
  value = data.google_compute_default_service_account.default.email
}
