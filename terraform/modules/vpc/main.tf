data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project}-${var.environment}-vpc"
    }
  )
}

resource "aws_default_security_group" "default_sg" {
  vpc_id = aws_vpc.vpc.id
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.public_subnets_cidr)
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true
  depends_on              = [aws_vpc.vpc]

  tags = merge(
    var.default_tags,
    {
      VPC                                                                   = "${var.project}-${var.environment}"
      State                                                                 = "public"
      Name                                                                  = "${var.project}-${var.environment}-public-${count.index}"
      "kubernetes.io/cluster/${var.project}-${var.environment}-eks-cluster" = "owned"
      "kubernetes.io/role/elb"                                              = "1"
    }
  )
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_subnets_cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)
  depends_on        = [aws_vpc.vpc]

  tags = merge(
    var.default_tags,
    {
      VPC                                                                   = "${var.project}-${var.environment}"
      State                                                                 = "private"
      Name                                                                  = "${var.project}-${var.environment}-private-${count.index}"
      "kubernetes.io/cluster/${var.project}-${var.environment}-eks-cluster" = "owned"
      "kubernetes.io/role/internal-elb"                                     = "1"
    }
  )
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id     = aws_vpc.vpc.id
  depends_on = [aws_vpc.vpc]

  tags = merge(
    var.default_tags,
    {
      VPC  = "${var.project}-${var.environment}"
      Name = "${var.project}-${var.environment}-gw"
    }
  )
}

resource "aws_eip" "eip_nat_gw" {
  domain           = "vpc"
  public_ipv4_pool = "amazon"

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project}-${var.environment}-eip-nat-gw"
    }
  )
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.eip_nat_gw.id
  subnet_id     = aws_subnet.public_subnet[0].id
  depends_on    = [aws_internet_gateway.internet_gw]

  tags = merge(
    var.default_tags,
    {
      Name = "${var.project}-${var.environment}-nat-gw"
    }
  )
}

resource "aws_route_table" "public_route_table" {
  vpc_id     = aws_vpc.vpc.id
  depends_on = [aws_vpc.vpc]
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }

  tags = merge(
    var.default_tags,
    {
      Name  = "${var.project}-${var.environment}-public-rtb"
      State = "public"
    }
  )
}

resource "aws_route_table" "private_route_table" {
  vpc_id     = aws_vpc.vpc.id
  depends_on = [aws_vpc.vpc]

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = merge(
    var.default_tags,
    {
      Name  = "${var.project}-${var.environment}-private-rtb"
      State = "private"
    }
  )
}

resource "aws_route_table_association" "route_association_public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id

  depends_on = [
    aws_route_table.public_route_table,
    aws_subnet.public_subnet
  ]
}

resource "aws_route_table_association" "route_association_private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table.id

  depends_on = [
    aws_route_table.private_route_table,
    aws_subnet.private_subnet
  ]
}
