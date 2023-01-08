
resource "aws_security_group" "database_sg" {
  name = "${var.mysql_name}-database-sg"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "app_db" {
  engine = "mysql"
  allocated_storage = 10
  instance_class = var.instance_class
  db_name = var.db_name
  username = var.db_user
  password = var.db_password
  skip_final_snapshot = true
  publicly_accessible = true
  vpc_security_group_ids = [ aws_security_group.database_sg.id ]
}

