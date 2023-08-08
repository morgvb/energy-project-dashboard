# Create databases

resource "aws_db_instance" "project-db" {
  allocated_storage    = 10
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "13"
  instance_class      = "db.t2.micro"
  name                = "project_db"
  username            = "project_user"
  password            = "project_password"
  parameter_group_name = "default.postgres13"
  
  tags = {
    Name = "ProjectDB"
  }
}

resource "aws_db_instance" "visualization-db" {
  resource "aws_db_instance" "visualization_db" {
  allocated_storage    = 20
  storage_type        = "gp2"
  engine              = "postgres"
  engine_version      = "13"
  instance_class      = "db.t2.micro"
  name                = "visualization_db"
  username            = "visualization_user"
  password            = "visualization_password"
  parameter_group_name = "default.postgres13"
  
  tags = {
    Name = "VisualizationDB"
  }
}
}