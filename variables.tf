variable "tp_edition" {
  type        = string
  description = "Teleport edition"
  default     = "cloud"
}

variable "tp_domain" {
  type        = string
  description = "Domain to the Teleport proxy service"
}

variable "tp_tokens" {
  description = "Token definitions keyed by name"
  type = map(object({
    roles       = list(string)
    join_method = optional(string)
    aws = optional(object({
      iid_ttl = optional(string)
      allow = optional(list(object({
        arn     = optional(string)
        account = optional(string)
        regions = optional(list(string))
        role    = optional(string)
      })), [])
    }))
    github = optional(object({
      enterprise_server_host = optional(string)
      enterprise_slug        = optional(string)
      static_jwks            = optional(string)
      allow = optional(list(object({
        actor       = optional(string)
        environment = optional(string)
        ref         = optional(string)
        ref_type    = optional(string)
        repository  = optional(string)
        sub         = optional(string)
        workflow    = optional(string)
      })), [])
    }))
    gitlab = optional(object({
      domain      = optional(string)
      static_jwks = optional(string)
      allow = optional(list(object({
        ci_config_ref_uri     = optional(string)
        ci_config_sha         = optional(string)
        deployment_tier       = optional(string)
        environment           = optional(string)
        environment_protected = optional(bool)
        namespace_path        = optional(string)
        project_path          = optional(string)
        project_visibility    = optional(string)
        ref                   = optional(string)
        ref_type              = optional(string)
        user_email            = optional(string)
        user_id               = optional(string)
        user_login            = optional(string)
      })), [])
    }))
    kubernetes = optional(object({
      type = optional(string)
      allow = optional(list(object({
        service_account = optional(string)
      })), [])
      static_jwks = optional(object({
        jwks = optional(string)
      }))
    }))
    spacelift = optional(object({
      hostname = optional(string)
      allow = optional(list(object({
        caller_id   = optional(string)
        caller_type = optional(string)
        scope       = optional(string)
        space_id    = optional(string)
      })), [])
    }))
  }))
  default = {}

  validation {
    condition     = alltrue([for k, v in var.tp_tokens : contains(["ec2", "iam"], v.join_method)])
    error_message = "join method value is invalid"
  }
}

variable "tp_roles" {
  type = map(object({
    options = optional(object({
      cert_format             = optional(string)
      client_idle_timeout     = optional(string)
      disconnect_expired_cert = optional(bool)
      desktop_clipboard       = optional(string)
      enhanced_recording      = optional(list(string))
      forward_agent           = optional(bool)
      max_session_ttl         = optional(string)
      permit_x11_forwarding   = optional(bool)
      require_session_mfa     = optional(number)
      record_session = optional(object({
        default = optional(string)
        desktop = optional(bool)
        ssh     = optional(string)
      }))
      ssh_port_forwarding = optional(object({
        remote = optional(object({ enabled = optional(bool, false) }))
        local  = optional(object({ enabled = optional(bool, false) }))
      }))
    }), {})
    allow = optional(object({
      app_labels             = optional(map(list(string)))
      aws_role_arns          = optional(list(string))
      db_labels              = optional(map(list(string)))
      db_names               = optional(list(string))
      db_roles               = optional(list(string))
      db_users               = optional(list(string))
      logins                 = optional(list(string))
      kubernetes_groups      = optional(list(string))
      kubernetes_labels      = optional(map(list(string)))
      node_labels            = optional(map(list(string)))
      windows_desktop_logins = optional(list(string))
      rules = optional(list(object({
        resources = optional(list(string))
        verbs     = optional(list(string))
        where     = optional(string)
        actions   = optional(list(string))
      })))
    }), {})
    deny = optional(object({
      app_labels             = optional(map(list(string)))
      aws_role_arns          = optional(list(string))
      db_labels              = optional(map(list(string)))
      db_names               = optional(list(string))
      db_roles               = optional(list(string))
      db_users               = optional(list(string))
      logins                 = optional(list(string))
      kubernetes_groups      = optional(list(string))
      kubernetes_labels      = optional(map(list(string)))
      node_labels            = optional(map(list(string)))
      windows_desktop_logins = optional(list(string))
      rules = optional(list(object({
        resources = optional(list(string))
        verbs     = optional(list(string))
        where     = optional(string)
        actions   = optional(list(string))
      })))
    }), {})
  }))
  description = "Teleport role definitions"
  default     = {}
}

variable "tp_github_connector" {
  type = object({
    enabled = optional(bool, false)
    oauth_client = optional(object({
      id     = optional(string)
      secret = optional(string)
    }), {})
    team_mappings = optional(list(object({
      org   = string
      team  = string
      roles = list(string)
    })), [])
  })
  description = "GitHub OAuth connector settings"
  default     = {}

  validation {
    condition     = var.tp_github_connector.enabled == false || (var.tp_github_connector.enabled && alltrue([for x in var.tp_github_connector.team_mappings : try(length(x.org), 0) > 0]))
    error_message = "github organization must be defined for all team role mappings"
  }
}

variable "tp_okta_connector" {
  type = object({
    enabled      = optional(bool, false)
    metadata_url = optional(string)
    group_mappings = optional(list(object({
      group = string
      roles = list(string)
    })), [])
  })
  description = "Okta SAML connector settings"
  default     = {}

  validation {
    condition     = var.tp_okta_connector.enabled == false || (var.tp_okta_connector.enabled && try(length(var.tp_okta_connector.metadata_url), 0) > 0)
    error_message = "okta app's metadata url is required"
  }
}

variable "tp_saml_connector" {
  type = object({
    enabled                 = optional(bool, false)
    name                    = optional(string)
    display                 = optional(string)
    acs                     = optional(string)
    audience                = optional(string)
    cert                    = optional(string)
    entity_descriptor       = optional(string)
    entity_descriptor_url   = optional(string)
    issuer                  = optional(string)
    provider                = optional(string)
    service_provider_issuer = optional(string)
    sso                     = optional(string)
    attributes_mappings = optional(list(object({
      name  = string
      value = string
      roles = list(string)
    })), [])
  })
  description = "Generic SAML connector settings"
  default     = {}
}

