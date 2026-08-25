# The below code get the available availability zones in the region
# and creates a list of availability zones to use for the VPC and subnets.
# It also creates a list of public and private subnets for the VPC.




# Datasources
data "aws_availability_zones" "available" {
  state = "available"
}

# Locals Block
locals {

  # This creates a list of availability zones to use for the VPC and subnets. 
  #It slices the list of available AZs to only include the first 3.
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # This creates a list of public and private subnets for the VPC.
  # The below local variables are lists of CIDR blocks for the public and private subnets.

  public_subnets  = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k)]
  private_subnets = [for k, az in local.azs : cidrsubnet(var.vpc_cidr, var.subnet_newbits, k + 10)]
}
