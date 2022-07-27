resource "aws_db_instance" "db" {
  allocated_storage           = 20
  engine                      = "mysql"
  engine_version              = "5.7.37"
  instance_class              = "db.t3.micro"
  db_name                     = "project_db"
  username                    = "admin"
  password                    = var.db_passwd
  vpc_security_group_ids      = var.db_security_group_id
  db_subnet_group_name        = var.db_subnet_group_name
  multi_az                    = false
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  skip_final_snapshot         = true

}