data "aws_caller_identity" "self" {}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"
  tags = {
    Name = "databricks-customer-managed-vpc"
  }
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 0)
  availability_zone = "ap-northeast-1a"
  tags = {
    Name = "databricks-private-subnet-a"
  }
}

resource "aws_subnet" "private_subnet_c" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block = cidrsubnet(var.vpc_cidr, 8, 1)
  availability_zone = "ap-northeast-1c"
  tags = {
    Name = "databricks-private-subnet-c"
  }
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "databricks-private-route-table-a"
  }
}

resource "aws_route_table" "private_c" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "databricks-private-route-table-c"
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_a.id
}
resource "aws_route_table_association" "private_c" {
  subnet_id      = aws_subnet.private_subnet_c.id
  route_table_id = aws_route_table.private_c.id
}

# VPC Endpoints
resource "aws_vpc_endpoint" "s3" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.ap-northeast-1.s3"
  route_table_ids = [
    aws_route_table.private_a.id,
    aws_route_table.private_c.id
  ]
}

resource "aws_vpc_endpoint" "sts" {
  service_name      = "com.amazonaws.ap-northeast-1.sts"
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_c.id
  ]
}

resource "aws_vpc_endpoint" "kinesis" {
  service_name      = "com.amazonaws.ap-northeast-1.kinesis-streams"
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_c.id
  ]
}

resource "aws_vpc_endpoint" "ec2" {
  service_name      = "com.amazonaws.ap-northeast-1.ec2"
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_c.id
  ]
}

resource "aws_vpc_endpoint" "logs" {
  service_name      = "com.amazonaws.ap-northeast-1.logs"
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_c.id
  ]
}
resource "aws_vpc_endpoint" "monitoring" {
  service_name      = "com.amazonaws.ap-northeast-1.monitoring"
  vpc_id            = aws_vpc.vpc.id
  vpc_endpoint_type = "Interface"
  security_group_ids = [aws_security_group.vpc_endpoint_sg.id]
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_c.id
  ]
}

# Databricks Endpoint
resource "aws_vpc_endpoint" "databricks_scc_vpc_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02aa633bda3edbec0"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_c.id
  ]
}

resource "aws_vpc_endpoint" "databricks_workspace_vpc_endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.vpce.ap-northeast-1.vpce-svc-02691fd610d24fd64"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids = [
    aws_subnet.private_subnet_a.id,
    aws_subnet.private_subnet_c.id
  ]
}

### Security Groups ###
resource "aws_security_group" "databricks_instance_sg" {
  name   = "databricks_instance_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name   = "vpc_endpoint_sg"
  vpc_id = aws_vpc.vpc.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    security_groups = [aws_security_group.databricks_instance_sg.id]
  }
}

resource "aws_kms_key" "s3_kms_key" {
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags = {
    Name = "databricks-kms"
  }
}

resource "aws_kms_alias" "s3_key_alias" {
  name          = "alias/databricks-kms"
  target_key_id = aws_kms_key.s3_kms_key.key_id
}