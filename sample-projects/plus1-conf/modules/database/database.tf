data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket =  "xyz.tochukwu-terraform-states"
    key = var.network_state_key
    region = var.region
  }
}

resource "aws_db_subnet_group" "db_subnet_gp" {
  name = "db-${var.env_name}-subnet-group"
  description = "Database subnet group backed by a single private subnet"
  subnet_ids = [ 
    data.terraform_remote_state.network.outputs.private_subnet_id1,
    data.terraform_remote_state.network.outputs.private_subnet_id2,
  ]
  tags = {
    Name = "Plus1Conf-${var.env_name}-DbSubnetGroup"
  }
}

resource "aws_db_instance" "database_instance" {
  allocated_storage = 20
  max_allocated_storage = 30
  db_name = var.dbname 
  engine = "postgres"
  instance_class = var.env_name == "prod" ? "db.t4g.micro" : "db.t3.micro"
  username = var.username
  password = var.password
  multi_az = var.env_name == "prod" ? true : false
  skip_final_snapshot = var.env_name == "prod" ? false : true
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.db_subnet_gp.name
  vpc_security_group_ids = [ data.terraform_remote_state.network.outputs.db_sg_id ]
  tags = {
    Name = "Plus1Conf-${var.env_name}-DbInstance"
  }
}