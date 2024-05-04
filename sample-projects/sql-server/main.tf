terraform {
  required_version = ">= 1.7.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.48"
    }
  }
}

resource "aws_security_group" "database_sg" {
  name = "simple-database-sg"
  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "sql_express" {
  allocated_storage      = 20
  identifier             = "simple-express-db"
  engine                 = "sqlserver-ex" # SQL Server Express
  engine_version         = "15.00.4365.2.v1"
  instance_class         = "db.t3.micro"
  username               = var.db_user
  password               = var.db_pass
  skip_final_snapshot    = true
  multi_az               = false
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.database_sg.id]
}
