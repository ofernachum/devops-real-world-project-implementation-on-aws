# Resource-1: VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = merge(var.tags, { Name = "${var.environment_name}-vpc" })
  lifecycle {
    prevent_destroy = false
  }
}

# Resource-2: Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags   = merge(var.tags, { Name = "${var.environment_name}-igw" })
}

# Resource-3: Public Subnets
# This creates a public subnet in each availability zone (AZ) defined in the `local.azs` 
# variable. The `for_each` expression iterates over the list of AZs and their corresponding
# public subnet CIDR blocks, creating a subnet for each AZ with the correct CIDR block. 

# To reference the public subnets created with `for_each`, you can use the `aws_subnet.public` map,
# which will have the AZ names as keys and the subnet resources as values. For example, to get the ID
# of the public subnet in "us-east-1a", you can use `aws_subnet.public["us-east-1a"].id`. 
# To get a list of all public subnet IDs, you can use `[for s in aws_subnet.public : s.id]`.

resource "aws_subnet" "public" {
  for_each                = { for idx, az in local.azs : az => local.public_subnets[idx] }
  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.environment_name}-public-${each.key}"
  })
}

# Resource-4: Private Subnets
resource "aws_subnet" "private" {
  ############################################################################################
  # The for_each expression creates a map where the key is the AZ name and
  # the value is the corresponding private subnet CIDR block. 
  # This allows us to create a subnet for each AZ with the correct CIDR block:
  # Example output will be: { "us-east-1a" => "10.0.1.0/24", "us-east-1b" => "10.0.2.0/24" }

  for_each = { for idx, az in local.azs : az => local.private_subnets[idx] }
  ############################################################################################

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = each.key

  tags = merge(var.tags, {
    Name = "${var.environment_name}-private-${each.key}"
  })
}

# Resource-5: Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  tags = merge(var.tags, { Name = "${var.environment_name}-nat-eip" })
}

# Resource-6: NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = values(aws_subnet.public)[0].id # Return the first public subnet ID from the map of public subnets above.
  tags          = merge(var.tags, { Name = "${var.environment_name}-nat" })
  depends_on    = [aws_internet_gateway.igw]
}

# Resource-7: Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id # Points to the Internet Gateway for outbound internet access from the public subnets. 
  }
  tags = merge(var.tags, { Name = "${var.environment_name}-public-rt" })
}

# Resource-8: Public Route Table Associate to Public Subnet
resource "aws_route_table_association" "public_rt_assoc" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_rt.id
}

# Resource-9: Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id # Points to the NAT Gateway for outbound internet access from the private subnets.  
  }
  tags = merge(var.tags, { Name = "${var.environment_name}-private-rt" })
}

# Resource-10: Private Route Table Association to Private Subnet
resource "aws_route_table_association" "private_rt_assoc" {
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_rt.id
}
