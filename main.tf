locals {
  enabled = module.this.enabled

  tp_domain = var.tp_domain

  tp_aws_tokens        = { for k, v in var.tp_tokens : k => v if local.enabled && contains(["iam", "ec2"], v.join_method) }
  tp_github_tokens     = { for k, v in var.tp_tokens : k => v if local.enabled && contains(["github"], v.join_method) }
  tp_gitlab_tokens     = { for k, v in var.tp_tokens : k => v if local.enabled && contains(["gitlab"], v.join_method) }
  tp_spacelift_tokens  = { for k, v in var.tp_tokens : k => v if local.enabled && contains(["spacelift"], v.join_method) }
  tp_kubernetes_tokens = { for k, v in var.tp_tokens : k => v if local.enabled && contains(["kubernetes"], v.join_method) }

  tp_saml_connectors = var.tp_saml_connector.enabled ? {
    lower(coalesce(var.tp_saml_connector.name, var.tp_saml_connector.provider, var.tp_saml_connector.display)) = var.tp_saml_connector
  } : {}
}

resource "teleport_provision_token" "aws" {
  for_each = local.tp_aws_tokens

  version = "v2"

  metadata = {
    name = each.key
  }

  spec = {
    roles       = each.value.roles
    join_method = each.value.join_method
    aws_iid_ttl = each.value.aws.iid_ttl

    allow = [
      for x in each.value.aws.allow : {
        aws_arn     = x.arn
        aws_account = x.account
        aws_regions = x.regions
        aws_role    = x.role
      }
    ]
  }
}

resource "teleport_role" "this" {
  for_each = var.tp_roles

  version = "v7"

  metadata = {
    name = each.key
  }

  spec = {
    allow   = each.value.allow
    deny    = each.value.deny
    options = each.value.options
  }
}

resource "teleport_github_connector" "this" {
  count = var.tp_github_connector.enabled ? 1 : 0

  version = "v3"

  metadata = {
    name = "github"
  }

  spec = {
    display       = "GitHub"
    redirect_url  = "https://${var.tp_domain}/v1/webapi/github/callback"
    client_id     = var.tp_github_connector.oauth_client.id
    client_secret = var.tp_github_connector.oauth_client.secret

    teams_to_roles = [
      for x in var.tp_github_connector.team_mappings : {
        organization = x.org
        team         = x.team
        roles        = x.roles
    }]
  }

  depends_on = [
    teleport_role.this
  ]
}

resource "teleport_saml_connector" "this" {
  for_each = local.tp_saml_connectors

  version = "v2"

  metadata = {
    name = coalesce(each.value.name, each.key)
  }

  spec = {
    display               = var.tp_saml_connector.display
    audience              = var.tp_saml_connector.audience
    acs                   = var.tp_saml_connector.acs
    cert                  = var.tp_saml_connector.cert
    entity_descriptor     = var.tp_saml_connector.entity_descriptor
    entity_descriptor_url = var.tp_saml_connector.entity_descriptor_url
    issuer                = var.tp_saml_connector.issuer
    provider              = var.tp_saml_connector.provider
    sso                   = var.tp_saml_connector.sso

    attributes_to_roles = [
      for x in var.tp_saml_connector.attributes_mappings : {
        name  = x.name
        value = x.value
        roles = x.roles
      }
    ]
  }

  depends_on = [
    teleport_role.this
  ]
}

resource "teleport_saml_connector" "okta" {
  count = var.tp_okta_connector.enabled ? 1 : 0

  version = "v2"

  metadata = {
    name = "okta"
  }

  spec = {
    display                 = "Okta"
    acs                     = "https://${local.tp_domain}:443/v1/webapi/saml/acs/okta"
    audience                = "https://${local.tp_domain}:443/v1/webapi/saml/acs/okta"
    entity_descriptor_url   = var.tp_okta_connector.metadata_url
    service_provider_issuer = "https://${local.tp_domain}:443/v1/webapi/saml/acs/okta"

    attributes_to_roles = [
      for x in var.tp_okta_connector.group_mappings : {
        name  = "groups"
        value = x.group
        roles = x.roles
      }
    ]
  }

  depends_on = [
    teleport_role.this
  ]

  lifecycle {
    ignore_changes = [
      spec.entity_descriptor, # managed by teleport
      spec.issuer,            # managed by teleport
      spec.signing_key_pair,  # managed by teleport
      spec.sso,               # managed by teleport
    ]
  }
}
