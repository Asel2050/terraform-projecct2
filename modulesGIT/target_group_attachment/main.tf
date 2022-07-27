resource "aws_lb_target_group_attachment" "ec2_attachment" {
  count            = length(var.instance_id)
  target_group_arn = var.target_group_arn
  target_id        = var.instance_id[count.index]
}