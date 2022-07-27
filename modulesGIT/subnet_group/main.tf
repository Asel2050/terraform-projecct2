resource "aws_db_subnet_group" "subnet_group" {
  name       = "project_db_subnet_group"
  subnet_ids = var.subnet_id

  tags = {
    Name = "project_db_subnet_group"
  }
}