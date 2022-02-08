locals {
  public_subnets = {
    "${var.region}a" = var.public_subnet_cidrs[0]
    "${var.region}b" = var.public_subnet_cidrs[1]
  }
  private_subnets = {
    "${var.region}a" = var.private_subnet_cidrs[0]
    "${var.region}b" = var.private_subnet_cidrs[1]
  }
}

resource "aws_vpc" "Production_vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.ecs_cluster_name}-vpc"
  }
}

resource "aws_internet_gateway" "Production_igw" {
  vpc_id = aws_vpc.Production_vpc.id

  tags = {
    Name = "${var.ecs_cluster_name}-internet-gateway"
  }
}

resource "aws_subnet" "public" {
  count      = length(local.public_subnets)
  cidr_block = element(values(local.public_subnets), count.index)
  vpc_id     = aws_vpc.Production_vpc.id

  map_public_ip_on_launch = true
  availability_zone       = element(keys(local.public_subnets), count.index)

  tags = {
    Name = "${var.ecs_cluster_name}-service-public"
  }
}

resource "aws_subnet" "private" {
  count      = length(local.private_subnets)
  cidr_block = element(values(local.private_subnets), count.index)
  vpc_id     = aws_vpc.Production_vpc.id

  map_public_ip_on_launch = true
  availability_zone       = element(keys(local.private_subnets), count.index)

  tags = {
    Name = "${var.ecs_cluster_name}-service-private"
  }
}

resource "aws_default_route_table" "public" {
  default_route_table_id = aws_vpc.Production_vpc.main_route_table_id

  tags = {
    Name = "${var.ecs_cluster_name}-public"
  }
}

resource "aws_route" "public_internet_gateway" {
  count                  = length(local.public_subnets)
  route_table_id         = aws_default_route_table.public.id
  destination_cidr_block = var.destination_cidr_block
  gateway_id             = aws_internet_gateway.Production_igw.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public" {
  count                 = length(local.public_subnets)
  subnet_id             = element(aws_subnet.public.*.id, count.index)
  route_table_id        = aws_default_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.Production_vpc.id

  tags = {
    Name = "${var.ecs_cluster_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  count                = length(local.private_subnets)
  subnet_id            = element(aws_subnet.private.*.id, count.index)
  route_table_id       = aws_route_table.private.id
}

resource "aws_eip" "nat" {
  vpc = true

  tags = {
    Name = "${var.ecs_cluster_name}-eip"
  }
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id          = aws_eip.nat.id
  subnet_id              = aws_subnet.public[0].id

  tags = {
    Name = "${var.ecs_cluster_name}-nat-gw"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.destination_cidr_block
  nat_gateway_id         = aws_nat_gateway.nat-gw.id

  timeouts {
    create = "5m"
  }
}