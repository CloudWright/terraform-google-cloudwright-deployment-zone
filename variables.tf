variable "project_id" {
  type        = string
  description = "The id of the project to use for the deployment zone"
}

variable "region" {
  type        = string
  description = "The GCP region to deploy infrastructure to"
}

variable "deployment_zone_name" {
  type        = string
  description = "The display name of this deployment zone, shown in the CloudWright UI. Can contain spaces, special characters etc."
}

variable "deployment_zone_namespace" {
  type        = string
  description = "The 'slug' used to namespace resources created for this deployment zone. Should only contain lower-case letters, numbers, and hyphens"
}