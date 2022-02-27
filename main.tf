terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.11.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
}

resource "random_id" "random" {
  byte_length = 4
}
