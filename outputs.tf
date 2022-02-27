output "region" {
  value = var.region
}

output "service_name" {
  value = google_cloud_run_service.vault_service.name
}

output "service_url" {
  value = google_cloud_run_service.vault_service.status[0].url
}
