resource "random_id" "storage_bucket" {
  byte_length = 4
}

resource "google_storage_bucket" "vault_storage" {
  name     = "${local.prefix}-storage-${lower(random_id.storage_bucket.hex)}"
  location = var.region

  depends_on = [time_sleep.delay]
}
