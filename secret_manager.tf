locals {
  vault_config = {
    "storage" = {
      "gcs" = {
        "bucket"     = google_storage_bucket.vault_storage.name
        "ha_enabled" = "false"
      }
    }
    "listener" = {
      "tcp" = {
        "address"     = "0.0.0.0:8200"
        "tls_disable" = 1
      }
    }
    "seal" = {
      "gcpckms" = {
        "project"    = var.project
        "region"     = var.region
        "key_ring"   = google_kms_key_ring.vault_key_ring.name
        "crypto_key" = google_kms_crypto_key.vault_crypto_key.name
      }
    }
    "log_level"          = var.vault_log_level
    "ui"                 = var.vault_ui
    "disable_mlock"      = true
    "disable_clustering" = true
  }
}

resource "google_secret_manager_secret" "vault_config" {
  secret_id = "${var.name}-config"
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }

  depends_on = [time_sleep.delay]
}

resource "google_secret_manager_secret_version" "vault_config_version" {
  secret      = google_secret_manager_secret.vault_config.id
  secret_data = jsonencode(local.vault_config)
}
