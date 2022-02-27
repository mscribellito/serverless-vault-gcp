resource "google_storage_bucket" "vault_storage" {
  name     = "${var.name}-${lower(random_id.random.hex)}-storage"
  location = var.region

  depends_on = [time_sleep.delay]
}
