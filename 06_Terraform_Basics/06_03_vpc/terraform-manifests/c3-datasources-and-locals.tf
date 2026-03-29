# Datasources
data "aws_availability_zones" "available" {
  state = "available"
}

# Locals Block
locals {

  # Get the first 3 AZs. 0 is the starting index, 3 is the number of AZs to take.
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # Generate public and private subnet CIDR blocks using the cidrsubnet function. The index
  # k is used to create unique subnets for each AZ.

  # cidrsubnet(var.vpc_cidr, var.subnet_newbits, k) takes the VPC CIDR block, adds new bits to create smaller subnets, and uses
  # the index k to ensure each subnet is unique. For example, if var.vpc_cidr is "10.0.0.0/16" and var.subnet_newbits is 4,
  # the first public subnet (k=0) would be "10.0.0.0/20". The second public subnet (k=1) would be "10.0.16.0/20". 




  public_subnets = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k)]

  # The private subnets are created similarly but with an offset of 10 to ensure they do not overlap with the public subnets.
  private_subnets = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k + 10)]
}


