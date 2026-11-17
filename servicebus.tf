## ----------------------------------------------------------------------------
## Copyright 2026 Raring Group LLC
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
## ----------------------------------------------------------------------------
##
##  modules/servicebus/servicebus.tf
##
##  Creates an Azure Service Bus namespace and its queues, named and tagged through the SevenPico context module, exposing every azurerm_servicebus_namespace and azurerm_servicebus_queue argument.
## ----------------------------------------------------------------------------

## Service Bus Context
module "servicebus_context" {
  source  = "git::https://github.com/raringgroup/terraform-null-context.git?ref=v0.1.0"
  context = module.context.self

  attributes = ["sb"]
}


## Service Bus Namespace (not created when existing_namespace_id is set)
resource "azurerm_servicebus_namespace" "this" {
  count = module.servicebus_context.enabled && var.existing_namespace_id == null ? 1 : 0

  capacity                      = var.capacity
  local_auth_enabled            = var.local_auth_enabled
  location                      = var.location
  minimum_tls_version           = var.minimum_tls_version
  name                          = module.servicebus_context.id
  premium_messaging_partitions  = var.premium_messaging_partitions
  public_network_access_enabled = var.public_network_access_enabled
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  tags                          = module.servicebus_context.tags

  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key == null ? [] : [var.customer_managed_key]
    content {
      identity_id                       = customer_managed_key.value.identity_id
      infrastructure_encryption_enabled = customer_managed_key.value.infrastructure_encryption_enabled
      key_vault_key_id                  = customer_managed_key.value.key_vault_key_id
    }
  }

  dynamic "identity" {
    for_each = var.identity == null ? [] : [var.identity]
    content {
      identity_ids = identity.value.identity_ids
      type         = identity.value.type
    }
  }

  dynamic "network_rule_set" {
    for_each = var.network_rule_set == null ? [] : [var.network_rule_set]
    content {
      default_action                = network_rule_set.value.default_action
      ip_rules                      = network_rule_set.value.ip_rules
      public_network_access_enabled = network_rule_set.value.public_network_access_enabled
      trusted_services_allowed      = network_rule_set.value.trusted_services_allowed

      dynamic "network_rules" {
        for_each = network_rule_set.value.network_rules == null ? [] : network_rule_set.value.network_rules
        content {
          ignore_missing_vnet_service_endpoint = network_rules.value.ignore_missing_vnet_service_endpoint
          subnet_id                            = network_rules.value.subnet_id
        }
      }
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts == null ? [] : [var.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}


## Service Bus Queues (in the namespace created above, or in existing_namespace_id)
resource "azurerm_servicebus_queue" "this" {
  for_each = module.servicebus_context.enabled ? var.queues : {}

  name                                    = each.key
  namespace_id                            = try(azurerm_servicebus_namespace.this[0].id, var.existing_namespace_id)
  auto_delete_on_idle                     = each.value.auto_delete_on_idle
  batched_operations_enabled              = each.value.batched_operations_enabled
  dead_lettering_on_message_expiration    = each.value.dead_lettering_on_message_expiration
  default_message_ttl                     = each.value.default_message_ttl
  duplicate_detection_history_time_window = each.value.duplicate_detection_history_time_window
  express_enabled                         = each.value.express_enabled
  forward_dead_lettered_messages_to       = each.value.forward_dead_lettered_messages_to
  forward_to                              = each.value.forward_to
  lock_duration                           = each.value.lock_duration
  max_delivery_count                      = each.value.max_delivery_count
  max_message_size_in_kilobytes           = each.value.max_message_size_in_kilobytes
  max_size_in_megabytes                   = each.value.max_size_in_megabytes
  partitioning_enabled                    = each.value.partitioning_enabled
  requires_duplicate_detection            = each.value.requires_duplicate_detection
  requires_session                        = each.value.requires_session
  status                                  = each.value.status

  dynamic "timeouts" {
    for_each = each.value.timeouts == null ? [] : [each.value.timeouts]
    content {
      create = timeouts.value.create
      delete = timeouts.value.delete
      read   = timeouts.value.read
      update = timeouts.value.update
    }
  }
}
