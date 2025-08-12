resource "aws_s3_bucket" "databricks_cloud_storage" {
  bucket = "databricks-cloud-storage-${data.aws_caller_identity.self.account_id}"
}
resource "aws_s3_bucket_versioning" "databricks_cloud_storage" {
  bucket = aws_s3_bucket.databricks_cloud_storage.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "databricks_cloud_storage" {
  bucket = aws_s3_bucket.databricks_cloud_storage.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_kms_key.id
    }
    bucket_key_enabled = true
  }
  depends_on = [aws_s3_bucket_versioning.databricks_cloud_storage]
}

resource "aws_s3_bucket_policy" "databricks_cloud_storage" {
  bucket = aws_s3_bucket.databricks_cloud_storage.id
  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "MyPolicy",
    Statement = [
      {
        Sid    = "Grant Databricks Access",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.databricks_aws_account_id}:root"
        },
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        Resource = [
          aws_s3_bucket.databricks_cloud_storage.arn,
          "${aws_s3_bucket.databricks_cloud_storage.arn}/*"
        ],
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/DatabricksAccountId" = var.databricks_external_id
          }
        }
      },
      {
        Sid    = "Prevent DBFS from accessing Unity Catalog metastore",
        Effect = "Deny",
        Principal = {
          AWS = "arn:aws:iam::${var.databricks_aws_account_id}:root"
        },
        Action = "s3:*",
        Resource = [
          "${aws_s3_bucket.databricks_cloud_storage.arn}/unity-catalog",
          "${aws_s3_bucket.databricks_cloud_storage.arn}/unity-catalog/*"
        ]
      }
    ]
  })

  depends_on = [aws_s3_bucket_versioning.databricks_cloud_storage]
}