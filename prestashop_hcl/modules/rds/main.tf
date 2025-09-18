resource "aws_db_instance" "db" {
  identifier        = "${var.environment}-db"
  engine            = "mysql"
  instance_class    = var.instance_type
  username          = var.username
  password          = var.password
  allocated_storage = 20
  skip_final_snapshot = true
}