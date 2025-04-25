data "aws_availability_zones" "available" {
}

resource "aws_vpc" "jenkins_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name  = "jenkins_vpc"
    Owner = var.owner_tag
  }
}

resource "aws_internet_gateway" "jenkins_igw" {
  vpc_id = aws_vpc.jenkins_vpc.id
  tags = {
    Name  = "jenkins_igw"
    Owner = var.owner_tag
  }
}

resource "aws_subnet" "jenkins_private_subnet_1" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = "10.0.0.0/19"
  availability_zone = "us-east-1a"
  tags = {
    Name                                        = "jenkins_private_subnet_1"
    Owner                                       = var.owner_tag
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "jenkins_private_subnet_2" {
  vpc_id            = aws_vpc.jenkins_vpc.id
  cidr_block        = "10.0.32.0/19"
  availability_zone = "us-east-1b"
  tags = {
    Name                                        = "jenkins_private_subnet_2"
    Owner                                       = var.owner_tag
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "jenkins_public_subnet_1" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.0.64.0/19"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "jenkins_public_subnet_1"
    Owner                                       = var.owner_tag
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "jenkins_public_subnet_2" {
  vpc_id                  = aws_vpc.jenkins_vpc.id
  cidr_block              = "10.0.96.0/19"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                                        = "jenkins_public_subnet_2"
    Owner                                       = var.owner_tag
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_eip" "jenkins_nat" {
  tags = {
    Name  = "jenkins_nat"
    Owner = var.owner_tag
  }
}

resource "aws_nat_gateway" "jenkins_nat" {
  allocation_id = aws_eip.jenkins_nat.id
  subnet_id     = aws_subnet.jenkins_public_subnet_1.id
  tags = {
    Name  = "jenkins_nat"
    Owner = var.owner_tag
  }
  depends_on = [
    aws_internet_gateway.jenkins_igw
  ]
}

resource "aws_route_table" "jenkins_route_table_private" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      nat_gateway_id             = aws_nat_gateway.jenkins_nat.id
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      gateway_id                 = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name  = "jenkins_route_table_private"
    Owner = var.owner_tag
  }
}

resource "aws_route_table" "jenkins_route_table_public" {
  vpc_id = aws_vpc.jenkins_vpc.id

  route = [
    {
      cidr_block                 = "0.0.0.0/0"
      gateway_id                 = aws_internet_gateway.jenkins_igw.id
      nat_gateway_id             = ""
      carrier_gateway_id         = ""
      destination_prefix_list_id = ""
      egress_only_gateway_id     = ""
      instance_id                = ""
      ipv6_cidr_block            = ""
      local_gateway_id           = ""
      network_interface_id       = ""
      transit_gateway_id         = ""
      vpc_endpoint_id            = ""
      vpc_peering_connection_id  = ""
    },
  ]

  tags = {
    Name  = "jenkins_route_table_public"
    Owner = var.owner_tag
  }
}

resource "aws_route_table_association" "jenkins_private_1" {
  subnet_id      = aws_subnet.jenkins_private_subnet_1.id
  route_table_id = aws_route_table.jenkins_route_table_private.id
}

resource "aws_route_table_association" "jenkins_private_2" {
  subnet_id      = aws_subnet.jenkins_private_subnet_2.id
  route_table_id = aws_route_table.jenkins_route_table_private.id
}

resource "aws_route_table_association" "jenkins_public_1" {
  subnet_id      = aws_subnet.jenkins_public_subnet_1.id
  route_table_id = aws_route_table.jenkins_route_table_public.id
}

resource "aws_route_table_association" "jenkins_public_2" {
  subnet_id      = aws_subnet.jenkins_public_subnet_2.id
  route_table_id = aws_route_table.jenkins_route_table_public.id
}
