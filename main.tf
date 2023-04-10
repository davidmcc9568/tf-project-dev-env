# Create a Virtual Private Cloud (VPC) with a specific CIDR block of 10.95.0.0/16
resource "aws_vpc" "dm-vpc" {
  cidr_block           = "10.95.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "dev"
  }
}

# Create a public subnet with in the VPC
resource "aws_subnet" "dm_public_subnet" {
  vpc_id                  = aws_vpc.dm-vpc.id
  cidr_block              = "10.95.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-west-2a"

  #Tag the subnet with a name for easier identification
  tags = {
    Name = "dev-public"
  }
}

# Create an Internet Gateway and attach to the VPC
resource "aws_internet_gateway" "dm_internet_gateway" {
  vpc_id = aws_vpc.dm-vpc.id

  # Tag the Internet Gateway with a name for easier identification
  tags = {
    Name = "dev-igw"
  }
}

# Create a route table for the VPC
resource "aws_route_table" "dm_public_rt" {
  vpc_id = aws_vpc.dm-vpc.id

  # Tag the route table with a name for easier identification
  tags = {
    Name = "dev-public-rt"
  }
}
# Specify a default route within the route table, associating it with the Internet Gateway
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.dm_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.dm_internet_gateway.id
}

# Associate the public subnet with the route table
resource "aws_route_table_association" "dm_public_assoc_subnet" {
  subnet_id      = aws_subnet.dm_public_subnet.id
  route_table_id = aws_route_table.dm_public_rt.id
}

# Create a security group within the VPC
resource "aws_security_group" "dm_sg" {
  name        = "dev_sg"
  description = "dev security group"
  vpc_id      = aws_vpc.dm-vpc.id

  # This ingress allows all traffic into the sg.  When running this, replace with your ip addresss for security
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Import an existing public key to use for SSH authentication
resource "aws_key_pair" "dm_auth" {
  key_name = "dmkey"
  public_key = file("~/.ssh/dmkey.pub")
}

# Launch an EC2 instance using AMI specified in datasources.tf
resource "aws_instance" "dev_node" {
  instance_type = "t2.micro"
  ami = data.aws_ami.server_ami.id 
  key_name = aws_key_pair.dm_auth.id
  vpc_security_group_ids = [aws_security_group.dm_sg.id]
  subnet_id = aws_subnet.dm_public_subnet.id 
  user_data = file("userdata.tpl")

  # Configured the root block device with a volume size of 10, rather than the default 8
  root_block_device {
    volume_size = 10
  }

  tags = {
    "Name" = "dev-node"
  }

  #Provision the instance using a local-exec provisioner to run a command based on the host operating system (Windows or Linux)
  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip,
      user = "ubuntu",
      identityfile = "~/.ssh/dmkey"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
}

