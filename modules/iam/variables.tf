variable "project_name" {
  description = "Project name for tagging resources"
  type        = string
  default     = "aws-devops-project"
}

variable "bucket_name" {
  description = "Name of the S3 bucket for log storage"
  type        = string
}
