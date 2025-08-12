variable "vpc_cidr" {
  type = string
}

variable "databricks_aws_account_id" {
  type        = string
  description = "Databricks の AWS アカウントID（数字のみ）"
  default     = "414351767826"
}

variable "databricks_external_id" {
  type        = string
  description = "Databricks から指定される External ID（ワークスペース/アカウントに紐づく値）"
}
