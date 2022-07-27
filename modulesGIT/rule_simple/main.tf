resource "aws_security_group_rule" "rule" {
  count             = length(var.rules)
  type              = var.type
  cidr_blocks       = [element(var.rules[count.index], 0)]
  from_port         = element(var.rules[count.index], 1)
  to_port           = element(var.rules[count.index], 2)
  protocol          = element(var.rules[count.index], 3)
  description       = element(var.rules[count.index], 4)
  security_group_id = var.security_group_id 


}