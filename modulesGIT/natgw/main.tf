resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.natgw_eip.id 
  subnet_id     = var.subnet_id

  tags = {
    Name = "project_natgw"
  }

  depends_on = [
    aws_eip.natgw_eip
  ]
}

resource "aws_eip" "natgw_eip" {
  vpc = true 

  tags = {
    Name = "project_eip"
  }
}
  
