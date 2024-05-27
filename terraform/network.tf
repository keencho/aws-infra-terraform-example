########## VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.app_name}-vpc"
  }
}

########## Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-igw"
  }
}

########## NAT Gateways
resource "aws_eip" "nat" {
  count = length(var.public_subnet_cidrs)
  vpc   = true

  tags = {
    Name = "${var.app_name}-nat-eip-${element(var.availability_zones, count.index)}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.public_subnet_cidrs)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = element(aws_subnet.public[*].id, count.index)

  tags = {
    Name = "${var.app_name}-nat-${element(var.availability_zones, count.index)}"
  }

  depends_on = [aws_internet_gateway.igw]
}

########## Route Tables
resource "aws_route_table" "rt-public" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-rt-public"
  }
}

# rt-public as default routing table
resource "aws_main_route_table_association" "main" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route_table_association" "rt-public-association" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.rt-public.id
}

resource "aws_route" "route-public" {
  route_table_id         = aws_route_table.rt-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table" "rt-private" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.app_name}-rt-private-${element(var.availability_zones, count.index)}"
  }
}

resource "aws_route" "route-private" {
  count                = length(var.private_subnet_cidrs)
  route_table_id       = element(aws_route_table.rt-private[*].id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id       = element(aws_nat_gateway.nat[*].id, count.index)
}

resource "aws_route_table_association" "rt-private-association" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(aws_route_table.rt-private[*].id, count.index)
}

resource "aws_route_table_association" "rt-private-db-association" {
  count          = length(var.db_subnet_cidrs)
  subnet_id      = element(aws_subnet.private-db[*].id, count.index)
  route_table_id = element(aws_route_table.rt-private[*].id, count.index)
}

########## Subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}${element(var.availability_zones, count.index)}"

  tags = {
    Name = "${var.app_name}-subnet-public-${element(var.availability_zones, count.index)}"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = "${var.aws_region}${element(var.availability_zones, count.index)}"

  tags = {
    Name = "${var.app_name}-subnet-private-${element(var.availability_zones, count.index)}"
  }
}

resource "aws_subnet" "private-db" {
  count             = length(var.db_subnet_cidrs)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.db_subnet_cidrs, count.index)
  availability_zone = "${var.aws_region}${element(var.availability_zones, count.index)}"

  tags = {
    Name = "${var.app_name}-subnet-db-private-${element(var.availability_zones, count.index)}"
  }
}
