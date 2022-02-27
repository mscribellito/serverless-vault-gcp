resource "google_service_account" "service_account" {
  account_id   = "${var.name}-sa"
  display_name = "Vault Server Service Account"
}

resource "google_storage_bucket_iam_member" "storage_bucket_member" {
  bucket = google_storage_bucket.vault_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_secret_manager_secret_iam_member" "secret_manager_secret_member" {
  secret_id = google_secret_manager_secret.vault_config.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_kms_key_ring_iam_member" "kms_key_ring_member" {
  key_ring_id = google_kms_key_ring.vault_key_ring.id
  role        = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member      = "serviceAccount:${google_service_account.service_account.email}"
}
