# =========================================
# 1. FIND UBUNTU 24.04 AMI
# =========================================

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


# =========================================
# 2. CREATE ANSIBLE CONTROLLER
# =========================================

resource "aws_instance" "controller" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.controller_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.controller.id]

  key_name                    = var.key_pair_name
  associate_public_ip_address = true
  user_data                   = file("${path.module}/userdata/controller.sh")

  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "${var.project_name}-controller"
    Project = var.project_name
    Role    = "controller"
  }
}


# =========================================
# 3. CREATE 3 MONGODB SERVERS
# =========================================

resource "aws_instance" "mongodb" {
  count = var.mongodb_count

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.mongodb_instance_type
  subnet_id              = aws_subnet.private.id
  vpc_security_group_ids = [aws_security_group.mongodb.id]

  key_name                    = var.key_pair_name
  associate_public_ip_address = false


  root_block_device {
    volume_size           = var.root_volume_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  metadata_options {
    http_tokens = "required"
  }

  tags = {
    Name    = "mongodb-${format("%02d", count.index + 1)}"
    Project = var.project_name
    Role    = "mongodb"
  }
}