variable "scheduling_active" {
  default = "Yes"
  allowed_values = ["Yes", "No"]
  description = "Activate or deactivate scheduling."
}
variable "scheduled_services" {
  default = "ec2"
  allowed_values = ["ec2", "rds", "both"]
  description = "Scheduled Services"
}
variable "schedule_rds_clusters" {
  default = "No"
  allowed_values = ["Yes", "No"]
  description  = "Enable scheduling of Aurora clusters for rds Service."
}
variable "create_rds_snapshot" {
  default = "No"
  allowed_values = ["Yes", "No"]
}
vairable "memory_size" {
  default = 128
  allowed_values = [128, 256, 512, 1024]
  description = "Size of the Lambda function running the scheduler, increase size when processing large numbers of instances."
}
variable "use_cloudwatch_metrics" {
  default = "No"
  allowed_values = ["Yes", "No"]
  description = "Collect instance scheduling data using CloudWatch metrics."
}
variable "log_retention_days" {
  default = 10 
  allowed_values = [1, 3, 5, 7, 14, 30]
  description = "Retention days for scheduler logs."
}
variable "trace" {
  default = "No"
  allowed_values = ["Yes", "No"]
  description = "Enable debug-level logging in CloudWatch logs."
}
variable "enable_ssm_maintenance_windows" {
  default = "No" 
  allowed_values = [ "Yes", "No"]
  description = "Enable the solution to load SSM Maintenance Windows, so that they can be used for ec2 instance Scheduling."
}
variable "tag_name" {
  default = "Schedule"
  description = "Name of tag to use for associating instance schedule schemas with service instances."
  max_length = 127
  min_length = 1
}
variable "default_time_zone" {
  default = "UTC"
  allowed_values = ["Africa/Lagos", "Africa/Johannesburg", "Europe/Amsterdam", "Europe/London",  "Europe/Paris"]
  description = "Choose the default Time Zone. Default is 'UTC'."
}
variable regions {
  type = list(string)
  description = "List of regions in which instances are scheduled, leave blank for current region only."
}
variable "using_aws_organizations" {
  default = false
  allowed_values = [true, false]
  description = "Is the hub account member of the AWS Organizations?"
}
variable "principals" {
  type = list(string)
  description = "(Required) If using AWS Organizations, provide Organization ID. Eg. o-xxxxyyy. Else, comma separated list of remote account ids. Eg.: 1111111111, 2222222222 or {param: ssm-param-name}"
}
variable "namespace" {
  type = string 
  description = "Provide unique identifier to differentiate between multiple solution deployments (No Spaces). Example: Dev"
}
variable "started_tags" {
  type = string
  description = "Comma separated list of tagname and values on the formt name=value,name=value,.. that are set on started instances"
}
variable "stopped_tags" {
  type = string 
  description = "Comma separated list of tagname and values on the formt name=value,name=value,.. that are set on stopped instances"
}
variable "scheduler_frequency" {
  default = "5"
  allowed_values = ["1", "2", "5", "10", "15", "30", "60"]
  description = "Scheduler running frequency in minutes."
}
variable "schedule_lambda_account" {
  default = "Yes"
  allowed_values = ["Yes", "No"]
}