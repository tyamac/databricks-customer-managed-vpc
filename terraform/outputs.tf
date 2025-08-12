output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "private_subnet_a" {
  value = aws_subnet.private_subnet_a.id
}

output "private_subnet_c" {
  value = aws_subnet.private_subnet_c.id
}

output "databricks_instance_sg" {
  value = aws_security_group.databricks_instance_sg.id
}

output "databricks_scc_vpc_endpoint" {
  value = aws_vpc_endpoint.databricks_scc_vpc_endpoint.id
}

output "databricks_workspace_vpc_endpoint" {
  value = aws_vpc_endpoint.databricks_workspace_vpc_endpoint.id
}

output "databricks_cloud_storage" {
  value = aws_s3_bucket.databricks_cloud_storage.id
}

output "databricks_cloud_storage_arn" {
  value = aws_s3_bucket.databricks_cloud_storage.arn
}

output "databricks_cross_account_access_role" {
  value = aws_iam_role.databricks_cross_account_access_role.id
}

output "databricks_cross_account_access_role_arn" {
  value = aws_iam_role.databricks_cross_account_access_role.arn
}
