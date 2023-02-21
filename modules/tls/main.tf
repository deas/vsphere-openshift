terraform {
  required_version = ">= 1.3"

  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

# ED25519 key - appears preferred by openshift
resource "tls_private_key" "ed25519" {
  algorithm = "ED25519"
}

resource "tls_cert_request" "api" {
  # file("private_key.pem")
  # private_key_pem = file("private_key.pem")
  private_key_pem = tls_private_key.ed25519.private_key_pem
  subject {
    common_name  = "api.${var.sub_domain}"
    organization = var.organization
  }
}

resource "tls_cert_request" "apps" {
  private_key_pem = tls_private_key.ed25519.private_key_pem
  subject {
    common_name  = "*.apps.${var.sub_domain}"
    organization = var.organization
  }
}