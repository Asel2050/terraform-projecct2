# create vpc:
module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/24"  
}


# create 2 public subnets for ALB
module "public_subnets" {
  source     = "./modules/public_subnet"
  cidr_block = ["10.0.0.0/26","10.0.0.64/26"]
  vpc_id     = module.vpc.vpc_id
}

#create 2 private subnets for EC2 and D
module "private_subnets" {
  source     = "./modules/private_subnet"
  cidr_block = ["10.0.0.128/26","10.0.0.192/26"]
  vpc_id     = module.vpc.vpc_id
}

#create igw:
module "igw" {
  source = "./modules/igw" 
  vpc_id = module.vpc.vpc_id 
}

# create natgw:
module "natgw" {
  source     = "./modules/natgw"
  subnet_id = module.public_subnets.public_subnet_id [0]
}

#create route table for public subnets, route www traffic to igw:
module "public_route_table" {
  source = "./modules/public_route_table"
  vpc_id = module.vpc.vpc_id
  igw_id = module.igw.igw_id
} 

#associate public route table with public subnet
module "rtb_public_subnet_association" {
  source         = "./modules/route_table_association"
  subnet_id      = [module.public_subnets.public_subnet_id[0], module.public_subnets.public_subnet_id[1]]
  route_table_id = module.public_route_table.public_route_table_id
}

#create route table for private subnets, route www traffic to natgw:
module "private_route_table" {
  source   = "./modules/private_route_table"
  vpc_id   = module.vpc.vpc_id
 natgw_id = module.natgw.natgw_id
}

#associate private route table with private subnet
module "rtb_private_subnet_association" {
  source         = "./modules/route_table_association"
  subnet_id      = [module.private_subnets.private_subnet[0],module.private_subnets.private_subnet[1]]
  route_table_id =  module.private_route_table.private_route_table_id
}

# create security group for ALB
module "alb_sg" {
  source  = "./modules/security_group"
  sg_name = "alb_sg"
  vpc_id  = module.vpc.vpc_id 
}

# add ingress rules for ALB security group:
module "alb_sg_ingress_rules" {
  source = "./modules/rule_simple"
  type   = "ingress"
  rules = {
    "0" = ["0.0.0.0/0", "80", "80", "TCP", "allow http from www"]
    "1" = ["0.0.0.0/0", "443", "443", "TCP", "allow https from www"]
  }
  security_group_id = module.alb_sg.sg_id
}

# add egress rules for ALB security group:
module "alb_sg_egress_rules" {
  source = "./modules/rule_simple"
  type   = "egress"
  rules = {
    "0" = ["0.0.0.0/0", "0", "65535", "TCP", "allow outbound traffic to www"]
  }
  security_group_id = module.alb_sg.sg_id
}

# create security group for web server EC2s:
module "ec2_sg" {
  source  = "./modules/security_group"
  sg_name = "ec2-sg"
  vpc_id  = module.vpc.vpc_id 
}

# add ingress rules for ec2 security group:
module "ec2_sg_ingress_rules" {
  source = "./modules/rule_simple"
  type   = "ingress"
  rules = {
    "0" = ["0.0.0.0/0", "22", "22", "TCP", "allow ssh from www"]
  }
  security_group_id = module.ec2_sg.sg_id
}

# add ingress rules for EC2 sg to allow http traffic from ALB sg:
module "ec2_sg_ingress_from_alb" {
  source = "./modules/rule_with_id"
  type   = "ingress" 
  rules = {
    "0" = [module.alb_sg.sg_id, "80", "80", "TCP", "allow http traffic from ALB"] 
  }
  security_group_id = module.ec2_sg.sg_id
}

# add egress rules for EC2 security group:
module "ec2_sg_egress_rules" {
  source = "./modules/rule_simple"
  type   = "egress"
  rules  = {
    "0"  = ["0.0.0.0/0", "0", "65535", "TCP", "allow outbound traffic to www"]
 }
 security_group_id = module.ec2_sg.sg_id
}

# create 2 ec2 in private subnets :
module "ec2" {
   source                = "./modules/ec2"
   subnet_id             = [module.private_subnets.private_subnet[0], module.private_subnets.private_subnet[1]]
   vpc_security_group_id = [module.ec2_sg.sg_id]

   depends_on =[
    module.natgw
   ]
}

#create target_group of EC2:
module "target_group" {
  source = "./modules/target_group"
  vpc_id = module.vpc.vpc_id 
} 

# attach both EC2s to target group:
module "ec2_attachment" {
  source           = "./modules/target_group_attachment"
  target_group_arn = module.target_group.target_group_arn 
  instance_id      = [module.ec2.instance_id[0], module.ec2.instance_id[1]]
}

#create alb:
module "alb" {
  source            = "./modules/alb"
  alb_sg            = [module.alb_sg.sg_id]
  alb_subnets       = [module.public_subnets.public_subnet_id[0], module.public_subnets.public_subnet_id[1]]
  target_group_arn  = module.target_group.target_group_arn
}

# create db subnet group:
module "db_subnet_group" {
  source    = "./modules/subnet_group"
  subnet_id = [module.private_subnets.private_subnet[0], module.private_subnets.private_subnet[1]]
}

# create db security group:
module "db_sg" {
  source  = "./modules/security_group"
  sg_name = "db-sg"
  vpc_id  = module.vpc.vpc_id
}

# add ingress rules for db sg to allow http traffic from EC2 sg:
module "db_sg_ingress_from_ec2" {
  source = "./modules/rule_with_id"
  type   = "ingress"
  rules  = {
    "0"  = [module.ec2_sg.sg_id, "3306", "3306", "TCP", "allow http traffic from EC2"]
  }
  security_group_id = module.db_sg.sg_id 
}

#add egress rules for db sg:
module "db_sg_egress_rules" {
  source = "./modules/rule_simple"
  type   = "egress"
  rules  = {
    "0"  = ["0.0.0.0/0", "0", "65535", "TCP", "allow outbound traffic to www"]
  }
  security_group_id = module.db_sg.sg_id
}

# create db:
module "db" {
  source               = "./modules/rds"
  db_security_group_id = [module.db_sg.sg_id]
  db_subnet_group_name = module.db_subnet_group.db_subnet_group_id
}

#create dns:
module "dns_record" {
  source       = "./modules/dns"
  alb_dns_name = [module.alb.alb_dns_name]
}