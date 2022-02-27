resource "google_cloud_run_service" "vault_service" {
  name     = "${var.name}-server"
  location = var.region

  traffic {
    percent         = 100
    latest_revision = true
  }

  template {
    spec {
      containers {
        image = "gcr.io/${var.project}/${var.image}"
        args  = ["server"]
        env {
          name = "VAULT_LOCAL_CONFIG"
          value_from {
            secret_key_ref {
              name = google_secret_manager_secret.vault_config.secret_id
              key  = "latest"
            }
          }
        }
        dynamic "env" {
          for_each = local.service_env_vars
          content {
            name  = env.value.name
            value = env.value.value
          }
        }
        ports {
          name           = "http1"
          container_port = 8200
        }
        resources {
          limits = {
            cpu    = "1000m"
            memory = "256Mi"
          }
        }
      }
      service_account_name = google_service_account.service_account.email
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = 1
      }
    }
  }

  metadata {
    namespace = var.project
  }

  depends_on = [time_sleep.delay]
}
