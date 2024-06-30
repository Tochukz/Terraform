
data "aws_availability_zones" "zones" {
}

data "aws_region" "current" {
}

locals {
  vpc = {
    cidr = "10.0.0.0/16"
  }
  public_one = {
    cidr = "10.0.0.0/24"
  }
  public_two = {
    cidr = "10.0.1.0/24"
  }
  public_three = {
    cidr = "10.0.2.0/24"
  }
  private_one = {
    cidr = "10.0.100.0/24"
  }
  private_two = {
    cidr = "10.0.101.0/24"
  }
  private_three = {
    cidr = "10.0.102.0/24"
  }
  zones  = data.aws_availability_zones.zones.names
  region = data.aws_region.current.name
}
