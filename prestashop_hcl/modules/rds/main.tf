# create database subnet group
resource "aws_db_subnet_group" "database_subnet_group" {
  name        = "${var.project_name}-${var.environment}-database-subnets"
  subnet_ids  = [aws_subnet.private_subnet_az1.id, aws_subnet.private_subnet_az2.id]
  description = "subnets for database instance"

  tags = {
    Name = "${var.project_name}-${var.environment}-database-subnets"
  }
}

# create a database instance
resource "aws_db_instance" "database_instance" {
  identifier     = "${var.project_name}-db"
  engine         = "mysql"
  engine_version = "8.0.31"
  instance_class = "db.t3.micro"
  db_name  = "prestashop-db"
  username = "prestashop"
  password = "var.db_password"
  allocated_storage = 200
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = [aws_db_subnet_group.main.name]
  availability_zone      = data.aws_availability_zones.available.names[0]
  multi_az              = false
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name        = "${var.project_name}-db"
    Environment = var.environment
  }
}
