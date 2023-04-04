resource "aws_vpc" "dm-vpc" {
  cidr_block           = "10.95.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

resource "aws_subnet" "dm_public_subnet" {
  vpc_id                  = aws_vpc.dm-vpc.id
  cidr_block              = "10.95.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  tags = {
    Name = "dev-public"
  }
}

resource "aws_internet_gateway" "dm_internet_gateway" {
  vpc_id = aws_vpc.dm-vpc.id

  tags = {
    Name = "dev-igw"
  }
}

resource "aws_route_table" "dm_public_rt" {
    vpc_id = aws_vpc.dm-vpc.id

    tags = {
        Name = "dev-public-rt"
    }
}
# specify the route within the route table
resource "aws_route" "default_route" {
  route_table_id = aws_route_table.dm_public_rt.id 
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.dm_internet_gateway.id
}

