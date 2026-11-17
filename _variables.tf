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
##  modules/servicebus/_variables.tf
##
##  Input variables for the servicebus module.
## ----------------------------------------------------------------------------

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the Service Bus namespace. Changing this forces a new resource to be created."
}

variable "location" {
  type        = string
  description = "Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
}

variable "existing_namespace_id" {
  type        = string
  description = "The ID of an existing Service Bus namespace. When set, the module creates only the queues, in that namespace, and does not create a namespace; the namespace arguments (resource_group_name, location, capacity, sku and so on) are then ignored and can be null. When null, the module creates the namespace and the queues."

  validation {
    condition     = var.existing_namespace_id == null || can(regex("(?i)^/subscriptions/[^/]+/resourceGroups/[^/]+/providers/Microsoft.ServiceBus/namespaces/[^/]+$", var.existing_namespace_id))
    error_message = "existing_namespace_id must be a Service Bus namespace resource ID, for example /subscriptions/<subscription-id>/resourceGroups/<resource-group>/providers/Microsoft.ServiceBus/namespaces/<name>."
  }
}

variable "capacity" {
  type        = number
  description = "Specifies the capacity. When sku is Premium, capacity can be 1, 2, 4, 8 or 16. When sku is Basic or Standard, capacity can be 0 only."
}

variable "local_auth_enabled" {
  type        = bool
  description = "Whether or not SAS authentication is enabled for the Service Bus namespace. Defaults to true."
}

variable "minimum_tls_version" {
  type        = string
  description = "The minimum supported TLS version for this Service Bus Namespace. Possible values are 1.2 and 1.3. Defaults to 1.2."
}

variable "premium_messaging_partitions" {
  type        = number
  description = "Specifies the number messaging partitions. Only valid when sku is Premium and the minimum number is 1. Possible values include 0, 1, 2, and 4. Defaults to 0 for Standard, Basic namespace. Changing this forces a new resource to..."
}

variable "public_network_access_enabled" {
  type        = bool
  description = "Is public network access enabled for the Service Bus Namespace? Defaults to true."
}

variable "sku" {
  type        = string
  description = "Defines which tier to use. Options are Basic, Standard or Premium. Please note that setting this field to Premium will force the creation of a new resource."
}

variable "customer_managed_key" {
  type = object({
    identity_id                       = string
    infrastructure_encryption_enabled = optional(bool)
    key_vault_key_id                  = string
  })
  description = "An customer_managed_key block as defined below."
}

variable "identity" {
  type = object({
    identity_ids = optional(set(string))
    type         = string
  })
  description = "An identity block as defined below."
}

variable "network_rule_set" {
  type = object({
    default_action                = optional(string)
    ip_rules                      = optional(set(string))
    public_network_access_enabled = optional(bool)
    trusted_services_allowed      = optional(bool)
    network_rules = optional(list(object({
      ignore_missing_vnet_service_endpoint = optional(bool)
      subnet_id                            = string
    })))
  })
  description = "An network_rule_set block as defined below."
}

variable "timeouts" {
  type = object({
    create = optional(string)
    delete = optional(string)
    read   = optional(string)
    update = optional(string)
  })
  description = "The timeouts block of azurerm_servicebus_namespace."
}

variable "queues" {
  type = map(object({
    auto_delete_on_idle                     = optional(string)
    batched_operations_enabled              = optional(bool)
    dead_lettering_on_message_expiration    = optional(bool)
    default_message_ttl                     = optional(string)
    duplicate_detection_history_time_window = optional(string)
    express_enabled                         = optional(bool)
    forward_dead_lettered_messages_to       = optional(string)
    forward_to                              = optional(string)
    lock_duration                           = optional(string)
    max_delivery_count                      = optional(number)
    max_message_size_in_kilobytes           = optional(number)
    max_size_in_megabytes                   = optional(number)
    partitioning_enabled                    = optional(bool)
    requires_duplicate_detection            = optional(bool)
    requires_session                        = optional(bool)
    status                                  = optional(string)
    timeouts = optional(object({
      create = optional(string)
      delete = optional(string)
      read   = optional(string)
      update = optional(string)
    }))
  }))
  description = "Service Bus queues keyed by queue name. Each value sets every azurerm_servicebus_queue argument except name and namespace_id; use null for an argument you do not want to set"
}
