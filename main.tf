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
  route_table_id         = aws_route_table.dm_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dm_internet_gateway.id
}

resource "aws_route_table_association" "dm_public_assoc_subnet" {
  subnet_id      = aws_subnet.dm_public_subnet.id
  route_table_id = aws_route_table.dm_public_rt.id
}

resource "aws_security_group" "dm_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.dm-vpc.id

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["192.168.0.7/32"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "dm_auth" {
  key_name = "dmkey"
  public_key = file("~/.ssh/dmkey.pub")
}

resource "aws_instance" "dev_node" {
  instance_type = "t2.micro"
  ami = data.aws_ami.server_ami.id 
  key_name = aws_key_pair.dm_auth.id
  vpc_security_group_ids = [aws_security_group.dm_sg.id]
  subnet_id = aws_subnet.dm_public_subnet.id 
  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "dev-node"
  }
}