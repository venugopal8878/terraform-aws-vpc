resource "aws_vpc" "main"{
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = var.enable_dns_hostnames


    tags = merge(
        var.common_tags,
        var.vpc_tags,
        {
            Name =local.resource_name
        }
    )
}

resource "aws_internet_gateway" "vgw" {
  vpc_id = aws_vpc.main.id

  tags =merge(
    var.common_tags,
    var.igw_tags,
 {
    Name = local.resource_name
  }
  )
}



resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidrs[count.index]
  availability_zone  = local.az_names[count.index]
  #public submnet we will enable it
  map_public_ip_on_launch = true #only we enabling for the public subnet default it is disable

  tags = merge(
    var.common_tags,
    var.public_subnet_tags,
  {
    Name = "${local.resource_name}-public-${local.az_names[count.index]}"
  }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidrs[count.index]
  availability_zone  = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.private_subnet_tags,
  {
    Name = "${local.resource_name}-private-${local.az_names[count.index]}"
  }
  )
}

resource "aws_subnet" "database" {
  count = length(var.database_subnet_cidrs)
  vpc_id     = aws_vpc.main.id
  cidr_block = var.database_subnet_cidrs[count.index]
  availability_zone  = local.az_names[count.index]

  tags = merge(
    var.common_tags,
    var.database_subnet_tags,
  {
    Name = "${local.resource_name}-database-${local.az_names[count.index]}"
  }
  )
}


resource "aws_db_subnet_group" "default" {
  name       = local.resource_name
  subnet_ids = aws_subnet.database[*].id #*means all 0 and 1 we have in database subnet

  tags =merge (
    var.common_tags,
    var.db_subnet_group,
   {
    Name = local.resource_name
  }
  )
}


resource "aws_eip" "nat" {
  domain   = "vpc"
}


resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id #getting from the eip 
  subnet_id     = aws_subnet.public[0].id #first pubic subnet we given so [0]

  tags = merge (
    var.common_tags,
    var.nat_gatway_tags,
    {
    Name = local.resource_name
  }
  )
  
  #to ensure proper ordering it is recommended to add an explicit dependency
  # on the internet gatway for the vpc
  depends_on = [aws_internet_gateway.main]
}