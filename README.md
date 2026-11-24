# terraform-azurerm-servicebus

Creates an Azure Service Bus namespace and its queues, named and tagged through the Raring Group context module, exposing every azurerm_servicebus_namespace and azurerm_servicebus_queue argument. It can also create only queues in a Service Bus namespace that already exists (see Using an existing namespace).

Part of the [Raring Group](https://github.com/raringgroup) Terraform module library.

## Usage

```hcl
module "servicebus" {
  source = "git::https://github.com/raringgroup/terraform-azurerm-servicebus.git?ref=v0.1.1"

  context = module.context.self

  resource_group_name           = "<value>"
  location                      = "<value>"
  existing_namespace_id         = null
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

Naming and tagging come from [`terraform-null-context`](https://github.com/raringgroup/terraform-null-context). Add `_context.tf` to the calling configuration and pass `context = module.context.self`.

Queues only, in an existing namespace:

```hcl
module "servicebus" {
  source = "git::https://github.com/raringgroup/terraform-azurerm-servicebus.git?ref=v0.1.1"

  context = module.context.self

  existing_namespace_id = "/subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ServiceBus/namespaces/<namespace-name>"

  # Namespace arguments are ignored in this mode
  resource_group_name           = null
  location                      = null
  capacity                      = null
  local_auth_enabled            = null
  minimum_tls_version           = null
  premium_messaging_partitions  = null
  public_network_access_enabled = null
  sku                           = null
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

## Design notes

The module uses `azurerm_servicebus_namespace` and `azurerm_servicebus_queue` directly. Queue names are the keys of `queues`. The root context is declared in `_context.tf`; it and the child contexts use `git::https://github.com/raringgroup/terraform-null-context.git?ref=v0.1.0`.

### Using an existing namespace

The module has two modes, chosen by `existing_namespace_id`:

| `existing_namespace_id` | What the module creates |
|-------------------------|-------------------------|
| `null` | The namespace and the queues in `queues`. |
| A namespace resource ID | Only the queues in `queues`, in that namespace. No namespace is created, changed or destroyed. |

In queues-only mode the namespace arguments (`resource_group_name`, `location`, `capacity`, `sku`, `identity`, `network_rule_set` and the rest) are ignored, so pass `null` for them. The `id` output returns the existing namespace ID; `endpoint` and `identity` are `null`, because the module does not read an existing namespace. The ID is validated to be a `Microsoft.ServiceBus/namespaces` resource ID. Queue names are the keys of `queues` in both modes, and the identity running Terraform needs permission to create queues in the existing namespace.

### Naming

Namespace names (used only when the module creates the namespace) are 6 to 50 characters: letters, digits and hyphens, starting with a letter and ending with a letter or digit. They must be globally unique. Queue names are not generated: they are the keys of `queues` and must be 1 to 260 characters (letters, digits, periods, hyphens, underscores and slashes), starting and ending with a letter or digit.

## Requirements, providers, inputs, outputs

### Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.3.0` |
| azurerm | `>= 4.0.0, < 5.0.0` |

### Inputs

Every azurerm argument is an input and every input is required (no defaults): pass `null` for an argument you do not want to set. Context inputs (`enabled`, `namespace`, `environment`, `stage`, `name`, `attributes`, `tags`, ...) are declared in `_context.tf`. The resource `name` and `tags` come from the context module, so they are not separate inputs. Deprecated azurerm arguments are not exposed. Nested block inputs are typed objects whose attributes follow the azurerm documentation for that block (https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_namespace, https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/servicebus_queue).

| Name | Type | Description |
|------|------|-------------|
| resource_group_name | `string` | The name of the resource group in which to create the Service Bus namespace. Changing this forces a new resource to be created. |
| location | `string` | Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created. |
| existing_namespace_id | `string` | The ID of an existing Service Bus namespace. When set, the module creates only the queues, in that namespace, and does not create a namespace; the namespace arguments are then ignored and can be null. When null, the module creates the namespace and the queues. |
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

### Outputs

| Name | Description |
|------|-------------|
| endpoint | Namespace endpoint (null when disabled or when an existing namespace is used) |
| id | Namespace ID: the one this module creates, or existing_namespace_id when that is set (null when disabled) |
| identity | Namespace managed identity, including principal and tenant IDs (null when disabled or when an existing namespace is used) |
| queue_ids | Map of queue name to queue ID |

Namespace shared access keys and connection strings are deliberately not output.

## Versioning

Releases follow semantic versioning and are tagged `vX.Y.Z`. Pin `?ref=` to a tag.

## Contributing

Work happens on `develop` through feature branches and pull requests. See the Raring Group gitflow standards.

## License

Apache-2.0. See [LICENSE](LICENSE) and [NOTICE](NOTICE).

`_context.tf` is derived from Cloud Posse's upstream module [terraform-null-label](https://github.com/cloudposse/terraform-null-label).
