# servicebus

Creates an Azure Service Bus namespace and its queues, named and tagged through the SevenPico context module, exposing every azurerm_servicebus_namespace and azurerm_servicebus_queue argument.

## Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.3.0` |
| azurerm | `>= 4.0.0, < 5.0.0` |

## Module Priority

No SevenPico, SevenPicoForks or CloudPosse module exists for Azure Service Bus, so the module uses `azurerm_servicebus_namespace` and `azurerm_servicebus_queue` directly. Queue names are the keys of `queues`. The root context is declared in `_context.tf`; it and the child contexts use `git::https://github.com/raringgroup/terraform-null-context.git?ref=v0.1.0`.

## Naming

Namespace names are 6 to 50 characters: letters, digits and hyphens, starting with a letter and ending with a letter or digit. They must be globally unique. Queue names are not generated: they are the keys of `queues` and must be 1 to 260 characters (letters, digits, periods, hyphens, underscores and slashes), starting and ending with a letter or digit.

## Inputs

Every azurerm argument is an input and every input is required (no defaults): pass `null` for an argument you do not want to set. Context inputs (`enabled`, `namespace`, `environment`, `stage`, `name`, `attributes`, `tags`, ...) are declared in `_context.tf`. The resource `name` and `tags` come from the context module, so they are not separate inputs. Deprecated azurerm arguments are not exposed. Nested block inputs are typed objects whose attributes follow the azurerm documentation for that block (https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace, https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue).

| Name | Type | Description |
|------|------|-------------|
| resource_group_name | `string` | The name of the resource group in which to create the Service Bus namespace. Changing this forces a new resource to be created. |
| location | `string` | Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. |
| capacity | `number` | Specifies the capacity. When sku is Premium, capacity can be 1, 2, 4, 8 or 16. When sku is Basic or Standard, capacity can be 0 only. |
| local_auth_enabled | `bool` | Whether or not SAS authentication is enabled for the Service Bus namespace. Defaults to true. |
| minimum_tls_version | `string` | The minimum supported TLS version for this Service Bus Namespace. Possible values are 1.2 and 1.3. Defaults to 1.2. |
| premium_messaging_partitions | `number` | Specifies the number messaging partitions. Only valid when sku is Premium and the minimum number is 1. Possible values include 0, 1, 2, and 4. Defaults to 0 for Standard, Basic namespace. Changing this forces a new resource to... |
| public_network_access_enabled | `bool` | Is public network access enabled for the Service Bus Namespace? Defaults to true. |
| sku | `string` | Defines which tier to use. Options are Basic, Standard or Premium. Please note that setting this field to Premium will force the creation of a new resource. |
| customer_managed_key | `object` | An customer_managed_key block as defined below. |
| identity | `object` | An identity block as defined below. |
| network_rule_set | `object` | An network_rule_set block as defined below. |
| timeouts | `object` | The timeouts block of azurerm_servicebus_namespace. |
| queues | `map(object)` | Queues keyed by queue name; every azurerm_servicebus_queue argument except name and namespace_id (including its own `timeouts`) |

## Outputs

| Name | Description |
|------|-------------|
| endpoint | Namespace endpoint (null when disabled) |
| id | Namespace ID (null when disabled) |
| identity | Namespace managed identity, including principal and tenant IDs (null when disabled) |
| queue_ids | Map of queue name to queue ID |

Namespace shared access keys and connection strings are deliberately not output.

## Usage

```hcl
terraform {
  source = "git::<repo-url>//modules/servicebus?ref=servicebus-v<version>"
}

inputs = {
  enabled     = true
  namespace   = "<namespace>"
  environment = "<environment>"
  stage       = "<stage>"
  name        = "<name>"

  resource_group_name           = "<value>"
  location                      = "<value>"
  capacity                      = null
  local_auth_enabled            = null
  minimum_tls_version           = null
  premium_messaging_partitions  = null
  public_network_access_enabled = null
  sku                           = "<value>"
  customer_managed_key          = null
  identity                      = null
  network_rule_set              = null
  timeouts                      = null

  queues = {
    "<queue-name>" = {
      max_delivery_count = 10
    }
  }
}
```

## License

Apache License 2.0. Copyright 2026 Raring Group LLC.
