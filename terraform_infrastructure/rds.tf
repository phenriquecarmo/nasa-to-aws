resource "aws_security_group" "postgres_sg" {
  name        = "postgres_sg"
  description = "Allow Postgres inbound traffic"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.allow_http_ssh.id]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["${var.user_ip}/32"]
  }

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Warning, this is not secure, I should probably move lambda to use internet with NAT Gateway but it is too expensive T-T, you should never use this aside from testing mode
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "postgres" {
  identifier              = "nasaws-db"
  allocated_storage       = 10
  storage_type            = "gp2"
  engine                  = "postgres"
  engine_version       = "15.12"
  instance_class          = "db.t3.micro"
  db_name                 = "nasaws_db"
  username                = var.db_username
  password                = var.db_password
  vpc_security_group_ids  = [aws_security_group.postgres_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = true
  multi_az                = false
  auto_minor_version_upgrade = true

  backup_retention_period = 0
}
