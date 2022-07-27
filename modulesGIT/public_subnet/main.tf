data "aws_availability_zones" "az" {
  state = "available"
}

resource "aws_subnet" "public_subnet" {
  count                   = length(var.cidr_block)
  availability_zone      = count.index % 2 == 0 ? data.aws_availability_zones.az.names [0] : data.aws_availability_zones.az.names[1]
  cidr_block              = var.cidr_block[count.index]
  map_public_ip_on_launch = true 
  vpc_id                  = var.vpc_id

  tags = {
    Name = "public_${count.index}"
  }
}

#uslovie ? true : false