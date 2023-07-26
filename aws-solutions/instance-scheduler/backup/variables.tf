variable "scheduling_active" {
  default     = "Yes"
  description = "Activate or deactivate scheduling."
  validation {
    condition     = contains(["Yes", "No"], var.scheduling_active)
    error_message = "sheduleing_active can only be 'Yes' or 'No'"
  }

}
variable "scheduled_services" {
  default     = "ec2"
  description = "Scheduled Services"
  validation {
    condition     = contains(["ec2", "rds", "both"], var.scheduled_services)
    error_message = "scheduled_services can only be 'ec2', 'rds' or 'both'"
  }
}
variable "schedule_rds_clusters" {
  default     = "No"
  description = "Enable scheduling of Aurora clusters for rds Service."
  validation {
    condition     = contains(["Yes", "No"], var.schedule_rds_clusters)
    error_message = "schedule_rds_clusters can only be 'Yes' or 'No'"
  }
}
variable "create_rds_snapshot" {
  default = "No"
  validation {
    condition     = contains(["Yes", "NO"], var.create_rds_snapshot)
    error_message = "create_rds_snapshot can only be 'Yes' or 'NO'"
  }
}
variable "memory_size" {
  default     = 128
  description = "Size of the Lambda function running the scheduler, increase size when processing large numbers of instances."
  validation {
    condition     = contains([128, 256, 512, 1024], var.memory_size)
    error_message = "memory_size must be 128, 256, 512 or 1024"
  }
}
variable "use_cloudwatch_metrics" {
  default     = "No"
  description = "Collect instance scheduling data using CloudWatch metrics."
  validation {
    condition     = contains(["Yes", "No"], var.use_cloudwatch_metrics)
    error_message = "use_cloudwatch_metrics must be either 'Yes' or 'No'"
  }
}
variable "log_retention_days" {
  default     = 10
  description = "Retention days for scheduler logs."
  validation {
    condition     = contains([1, 3, 5, 7, 14, 30], var.log_retention_days)
    error_message = "log_retention_days can only be 1, 3, 5, 7, 14 or 30"
  }
}
variable "trace" {
  default     = "No"
  description = "Enable debug-level logging in CloudWatch logs."
  validation {
    condition     = contains(["Yes", "No"], var.trace)
    error_message = "trace must be either 'Yes' or 'No'"
  }
}
variable "enable_ssm_maintenance_windows" {
  default     = "No"
  description = "Enable the solution to load SSM Maintenance Windows, so that they can be used for ec2 instance Scheduling."
  validation {
    condition     = contains(["Yes", "No"], var.enable_ssm_maintenance_windows)
    error_message = "enable_ssm_maintenance_windows must be either 'Yes' or 'No'"
  }
}
# variable "tag_name" {
#   default     = "Schedule"
#   description = "Name of tag to use for associating instance schedule schemas with service instances."
#   max_length  = 127
#   min_length  = 1
# }
# variable "default_time_zone" {
#   default        = "UTC"
#   allowed_values = ["Africa/Lagos", "Africa/Johannesburg", "Europe/Amsterdam", "Europe/London", "Europe/Paris"]
#   description    = "Choose the default Time Zone. Default is 'UTC'."
# }
# variable "regions" {
#   type        = list(string)
#   description = "List of regions in which instances are scheduled, leave blank for current region only."
# }
# variable "using_aws_organizations" {
#   default        = false
#   allowed_values = [true, false]
#   description    = "Is the hub account member of the AWS Organizations?"
# }
# variable "principals" {
#   type        = list(string)
#   description = "(Required) If using AWS Organizations, provide Organization ID. Eg. o-xxxxyyy. Else, comma separated list of remote account ids. Eg.: 1111111111, 2222222222 or {param: ssm-param-name}"
# }
variable "namespace" {
  type        = string
  description = "Provide unique identifier to differentiate between multiple solution deployments (No Spaces). Example: dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.namespace)
    error_message = "namespace should be dev, staging or prod"
  }
}
# variable "started_tags" {
#   type        = string
#   description = "Comma separated list of tagname and values on the formt name=value,name=value,.. that are set on started instances"
# }
# variable "stopped_tags" {
#   type        = string
#   description = "Comma separated list of tagname and values on the formt name=value,name=value,.. that are set on stopped instances"
# }
# variable "scheduler_frequency" {
#   default        = "5"
#   allowed_values = ["1", "2", "5", "10", "15", "30", "60"]
#   description    = "Scheduler running frequency in minutes."
# }
variable "schedule_lambda_account" {
  default = "Yes"
  validation {
    condition     = contains(["Yes", "No"], var.schedule_lambda_account)
    error_message = "schedule_lambda_account must be either 'Yes' or 'No'"
  }
}
