resource "google_kms_key_ring" "vault_key_ring" {
  name     = "${local.prefix}-key-ring"
  location = var.region

  depends_on = [time_sleep.delay]
}

resource "google_kms_crypto_key" "vault_crypto_key" {
  name     = "${local.prefix}-crypto-key"
  key_ring = google_kms_key_ring.vault_key_ring.id
}
