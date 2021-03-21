# ------------------------------
# VPC
# ------------------------------
resource "aws_vpc" "vpc" {
  cidr_block                       = var.vpc_cidr_block
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name    = "${var.project}-vpc"
    Project = var.project
  }
}

# ------------------------------
# Subnet
# ------------------------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  availability_zone       = var.availability_zone
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name    = "${var.project}-public-subnet"
    Project = var.project
  }
}

# ------------------------------
# Route table
# ------------------------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-public-rt"
    Project = var.project
  }
}

resource "aws_route_table_association" "public_rta" {
  route_table_id = aws_route_table.public_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}

# ------------------------------
# Internet Gateway
# ------------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name    = "${var.project}-igw"
    Project = var.project
  }
}

resource "aws_route" "public_rt_igw_r" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
