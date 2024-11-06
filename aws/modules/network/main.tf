resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr
  tags = {
    Name = var.vpc-name
  }
  enable_dns_support   = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  for_each          = local.subnets.public-subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${var.env-name}-${each.value.name}"
  }
}

resource "aws_subnet" "private" {
  for_each          = local.subnets.private-subnets
  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value.cidr
  availability_zone = each.value.az
  tags = {
    Name = "${var.env-name}-${each.value.name}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env-name}-igw"
  }
}

resource "aws_route_table" "rtb-public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env-name}-rtb-public"
  }
}

resource "aws_route_table_association" "rtb-assoc-pub" {
  for_each       = aws_subnet.public
  route_table_id = aws_route_table.rtb-public.id
  subnet_id      = each.value.id
}

resource "aws_route" "route-igw" {
  route_table_id         = aws_route_table.rtb-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_eip" "nat-gateway-ip-address" {
  domain = "vpc"
}

resource "aws_route_table" "rtb-private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env-name}-rtb-private"
  }
}

resource "aws_route_table_association" "rtb_assoc_prv" {
  for_each       = aws_subnet.private
  route_table_id = aws_route_table.rtb-private.id
  subnet_id      = each.value.id
}
/**
resource "aws_nat_gateway" "example-nat-gateway" {
  allocation_id = aws_eip.nat-gateway-ip-address.id
  subnet_id     = local.public-subnet-ids[0]

  tags = {
    Name = "gw-NAT-1st"
  }
}
**/


/**
resource "aws_route" "route-natgw" {
  route_table_id         = aws_route_table.rtb-private.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.example-nat-gateway.id
}
**/

# https://qiita.com/TaishiOikawa/items/8b9db3df76102096d159
locals {
  subnets = {
    private-subnets = {
      for key in var.private-subnets :
      key => {
        name = key,
        cidr = cidrsubnet(var.vpc-cidr, 8, index(var.private-subnets, key))
        az   = var.az-list[index(var.private-subnets, key) % length(var.az-list)]
      }
    },
    public-subnets = {
      for key in var.public-subnets :
      key => {
        name = key,
        cidr = cidrsubnet(var.vpc-cidr, 8, index(var.public-subnets, key) + length(var.private-subnets))
        az   = var.az-list[index(var.public-subnets, key) % length(var.az-list)]
      }
    }
  }

  public-subnet-ids = [for s in aws_subnet.public : s.id]

  private-subnet-ids = [for s in aws_subnet.private : s.id]
}

// VPC Endpoint用に仕方なく追加したもの
resource "aws_security_group" "vpc_endpoint" {
  name   = "vpc_endpoint_sg"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }
}

/**
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.private-subnet-ids
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.ap-northeast-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = local.private-subnet-ids
  security_group_ids  = [aws_security_group.vpc_endpoint.id]
  private_dns_enabled = true
}

**/
