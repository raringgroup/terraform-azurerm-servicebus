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
##  modules/servicebus/_outputs.tf
##
##  Output values for the servicebus module.
## ----------------------------------------------------------------------------

output "endpoint" {
  description = "Endpoint of the Service Bus namespace (null when disabled or when an existing namespace is used)"
  value       = try(azurerm_servicebus_namespace.this[0].endpoint, null)
}

output "id" {
  description = "Id of the Service Bus namespace: the one created by this module, or existing_namespace_id when that is set (null when disabled)"
  value       = module.servicebus_context.enabled ? try(azurerm_servicebus_namespace.this[0].id, var.existing_namespace_id) : null
}

output "identity" {
  description = "Identity of the Service Bus namespace (null when disabled or when an existing namespace is used)"
  value       = try(azurerm_servicebus_namespace.this[0].identity, null)
}

output "queue_ids" {
  description = "Map of queue name to queue ID"
  value       = { for k, v in azurerm_servicebus_queue.this : k => v.id }
}
