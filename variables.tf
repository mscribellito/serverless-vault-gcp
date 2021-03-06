variable "project" {
  type        = string
  description = "GCP Project Id."
}

variable "region" {
  type        = string
  description = "GCP Region."
  default     = "us-central1"
}

variable "apis_services" {
  type        = list(string)
  description = "APIs & Services to enable."
  default = [
    "cloudkms.googleapis.com",
    "run.googleapis.com",
    "secretmanager.googleapis.com",
    "storage.googleapis.com"
  ]
}

variable "name" {
  type        = string
  description = "Value to prefix resources with."
  default     = "vault"
}

variable "image" {
  type        = string
  description = "Vault image to deploy."
  default     = "vault:latest"
}

variable "vault_log_level" {
  type        = string
  description = "Specifies the log level to use."
  default     = "info"
}

variable "vault_ui" {
  type        = bool
  description = "Enables the built-in web UI."
  default     = false
}

locals {
  service_env_vars = [
    {
      name  = "SKIP_SETCAP"
      value = 1
    }
  ]
}
