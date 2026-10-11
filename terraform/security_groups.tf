# =========================================
# 1. CONTROLLER SECURITY GROUP
# =========================================

resource "aws_security_group" "controller" {
  name        = "${var.project_name}-controller-sg"
  description = "Security group for Ansible Controller"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-controller-sg"
  }
}


# Allow SSH from administrator public IP
resource "aws_vpc_security_group_ingress_rule" "controller_ssh" {
  security_group_id = aws_security_group.controller.id

  cidr_ipv4   = var.admin_ip_cidr
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  description = "SSH from administrator IP"
}


# Allow Controller outbound traffic
resource "aws_vpc_security_group_egress_rule" "controller_outbound" {
  security_group_id = aws_security_group.controller.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow outbound traffic"
}


# =========================================
# 2. MONGODB SECURITY GROUP
# =========================================

resource "aws_security_group" "mongodb" {
  name        = "${var.project_name}-mongodb-sg"
  description = "Security group for MongoDB servers"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-mongodb-sg"
  }
}


# Allow SSH from Controller
resource "aws_vpc_security_group_ingress_rule" "mongodb_ssh" {
  security_group_id = aws_security_group.mongodb.id

  referenced_security_group_id = aws_security_group.controller.id

  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"

  description = "SSH from Controller"
}


# Allow MongoDB connections from Controller
resource "aws_vpc_security_group_ingress_rule" "mongodb_controller" {
  security_group_id = aws_security_group.mongodb.id

  referenced_security_group_id = aws_security_group.controller.id

  from_port   = 27017
  to_port     = 27017
  ip_protocol = "tcp"

  description = "MongoDB access from Controller"
}


# Allow communication between MongoDB nodes
resource "aws_vpc_security_group_ingress_rule" "mongodb_replication" {
  security_group_id = aws_security_group.mongodb.id

  referenced_security_group_id = aws_security_group.mongodb.id

  from_port   = 27017
  to_port     = 27017
  ip_protocol = "tcp"

  description = "MongoDB Replica Set communication"
}


# Allow Prometheus to collect MongoDB metrics
resource "aws_vpc_security_group_ingress_rule" "mongodb_exporter" {
  security_group_id = aws_security_group.mongodb.id

  referenced_security_group_id = aws_security_group.controller.id

  from_port   = 9216
  to_port     = 9216
  ip_protocol = "tcp"

  description = "MongoDB Exporter access from Controller"
}


# Allow MongoDB outbound traffic via NAT
resource "aws_vpc_security_group_egress_rule" "mongodb_outbound" {
  security_group_id = aws_security_group.mongodb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  description = "Allow outbound traffic"
}