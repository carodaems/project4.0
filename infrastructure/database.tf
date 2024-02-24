# DB Subnet Group
resource "aws_db_subnet_group" "app_db_subnet_group" {
  name        = "flask-db-subnet-group"
  description = "Subnet group for Flask DB"
  subnet_ids  = module.vpc.private_subnets

}
# RDS for Microsoft SQL Server
resource "aws_db_instance" "app_db" {
  identifier              = "barometerdb"
  allocated_storage       = 20
  storage_type            = "gp2"
  engine                  = "sqlserver-ex"
  engine_version          = "16.00.4085.2.v1"
  instance_class          = "db.t3.micro"
  username                = local.db_secret["username"]
  password                = local.db_secret["password"]
  publicly_accessible     = false
  multi_az                = false
  backup_retention_period = 7
  skip_final_snapshot     = true
  vpc_security_group_ids  = [aws_security_group.rds.id]
  db_subnet_group_name    = aws_db_subnet_group.app_db_subnet_group.name

  tags = {
    Name        = "MyDBInstance"
    Environment = "Dev"
  }

}

