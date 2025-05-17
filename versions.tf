terraform {
  required_version = ">= 1.3.0"

  required_providers {
    teleport = {
      source  = "terraform.releases.teleport.dev/gravitational/teleport"
      version = "~> 17.0"
    }
  }
}
