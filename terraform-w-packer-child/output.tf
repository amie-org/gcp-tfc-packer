output "vm_external_ip_addr" {
  value = "http://${google_compute_instance.instance_with_ip.network_interface[0].access_config[0].nat_ip}"
}

output "default_gce_service_account" {
  value = data.google_compute_default_service_account.default.email
}
