# iam_databricks_cross_account_role.tf
data "aws_iam_policy_document" "databricks_trust" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "AWS"
      identifiers = ["arn:aws:iam::${var.databricks_aws_account_id}:root"]
    }
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [var.databricks_external_id]
    }
  }
}

resource "aws_iam_role" "databricks_cross_account_access_role" {
  name               = "databricks-cross-account-access-role"
  assume_role_policy = data.aws_iam_policy_document.databricks_trust.json

  tags = {
    Name = "databricks-cross-account-access-role"
  }
}

resource "aws_iam_policy" "databricks_cross_account_policy" {
  name        = "databricks-cross-account-policy"
  description = "Policy for Databricks cross-account workspace operations (as provided)."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Stmt1403287045000"
        Effect = "Allow"
        Action = [
          "ec2:AssociateIamInstanceProfile",
          "ec2:AttachVolume",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CancelSpotInstanceRequests",
          "ec2:CreateTags",
          "ec2:CreateVolume",
          "ec2:DeleteTags",
          "ec2:DeleteVolume",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeIamInstanceProfileAssociations",
          "ec2:DescribeInstanceStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNatGateways",
          "ec2:DescribeNetworkAcls",
          "ec2:DescribePrefixLists",
          "ec2:DescribeReservedInstancesOfferings",
          "ec2:DescribeRouteTables",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSpotInstanceRequests",
          "ec2:DescribeSpotPriceHistory",
          "ec2:DescribeSubnets",
          "ec2:DescribeVolumes",
          "ec2:DescribeVpcAttribute",
          "ec2:DescribeVpcs",
          "ec2:DetachVolume",
          "ec2:DisassociateIamInstanceProfile",
          "ec2:ReplaceIamInstanceProfileAssociation",
          "ec2:RequestSpotInstances",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeFleetHistory",
          "ec2:ModifyFleet",
          "ec2:DeleteFleets",
          "ec2:DescribeFleetInstances",
          "ec2:DescribeFleets",
          "ec2:CreateFleet",
          "ec2:DeleteLaunchTemplate",
          "ec2:GetLaunchTemplateData",
          "ec2:CreateLaunchTemplate",
          "ec2:DescribeLaunchTemplates",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:ModifyLaunchTemplate",
          "ec2:DeleteLaunchTemplateVersions",
          "ec2:CreateLaunchTemplateVersion",
          "ec2:AssignPrivateIpAddresses",
          "ec2:GetSpotPlacementScores"
        ]
        Resource = ["*"]
      },
      {
        Effect = "Allow"
        Action = [
          "iam:CreateServiceLinkedRole",
          "iam:PutRolePolicy"
        ]
        Resource = "arn:aws:iam::*:role/aws-service-role/spot.amazonaws.com/AWSServiceRoleForEC2Spot"
        Condition = {
          StringLike = {
            "iam:AWSServiceName" = "spot.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_cross_account_policy" {
  role       = aws_iam_role.databricks_cross_account_access_role.name
  policy_arn = aws_iam_policy.databricks_cross_account_policy.arn
}
