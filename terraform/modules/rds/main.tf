variable "identifier"      {}
variable "private_subnets" { type = list(string) }
variable "vpc_id"          {}
variable "eks_sg_id"       {}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnets"
  subnet_ids = var.private_subnets
}

resource "aws_security_group" "rds" {
  name   = "${var.identifier}-rds-sg"
  vpc_id = var.vpc_id
  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.eks_sg_id]
  }
}

resource "aws_db_instance" "this" {
  identifier             = var.identifier
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  username               = "appuser"
  manage_master_user_password = true
  skip_final_snapshot    = true
}

output "endpoint" { value = aws_db_instance.this.endpoint }
