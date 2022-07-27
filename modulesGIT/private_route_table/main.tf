resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id 

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.natgw_id 
  }  

  tags = {
    Name = "private_route_table"
  }
}
