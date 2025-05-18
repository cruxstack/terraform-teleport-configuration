# terraform-teleport-management

Opinionated Terraform module for **managing Teleport clusters**. It works for
both **Teleport Cloud** and **self-hosted cluster**. The module provisions and
maintains:

* **Provision tokens** (IAM/EC2, GitHub)
* **Roles** with allow/deny rules and options
* **Identity-provider connectors** (GitHub, Okta, generic SAML)

## Usage

```hcl
module "teleport" {
  source  = "cruxstack/management/teleport"
  version = "x.x.x"

  tp_domain = "teleport.example.com"

  tp_tokens = {
    node = {
      roles       = ["App", "Db", "Node"]
      join_method = "iam"
      aws = {
        allow = [{ account = "111111111111"}]
      }
    }
  }

  tp_github_connector = {
    enabled     = true
    oauth_client = {
      id     = "xxxxxxxxx"
      secret = "xxxxxxxxx"
    }
    team_mappings = [{
      org   = "cruxstack"
      team  = "developers"
      roles = ["access"]
    }]
  }
}
````

## Inputs

| Variable              | Type          | Default               | Description                                                  |
|-----------------------|-------------- |-----------------------|--------------------------------------------------------------|
| `enabled`             | `bool`        | `true`                | set to false to prevent the module from creating resources   |
| `tp_edition`          | `string`      | `"cloud"`             | teleport edition                                             |
| `tp_domain`           | `string`      | n/a                   | domain to the teleport proxy service                         |
| `tp_tokens`           | `map(object)` | `{}`                  | token definitions keyed by name                              |
| `tp_roles`            | `map(object)` | `{}`                  | teleport role definitions                                    |
| `tp_github_connector` | `object`      | `{ enabled = false }` | github oauth connector settings                              |
| `tp_okta_connector`   | `object`      | `{ enabled = false }` | okta saml connector settings                                 |
| `tp_saml_connector`   | `object`      | `{ enabled = false }` | generic saml connector settings                              |

## Outputs

| Name                  | Type            | Description                                               |
|-----------------------|-----------------|-----------------------------------------------------------|
| `token_ids`           | `list(string)`  | ids of all `teleport_provision_token` resources           |
| `role_names`          | `set(string)`   | set of role names managed by this module                  |
| `github_connector_id` | `string`        | id of the github connector (`null` when connector disabled)|
