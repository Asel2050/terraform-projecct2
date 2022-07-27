resource "aws_security_group" "security_group" {
  name       = var.sg_name
  vpc_id     = var.vpc_id
}