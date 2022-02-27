resource "google_project_service" "enable_apis_services" {
  for_each           = toset(var.apis_services)
  service            = each.value
  disable_on_destroy = false
}

resource "time_sleep" "delay" {
  depends_on      = [google_project_service.enable_apis_services]
  create_duration = "60s"
}
