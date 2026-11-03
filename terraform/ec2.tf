# =========================================
# 1. CREATE ANSIBLE CONTROLLER
# =========================================

resource "aws_instance" "controller" {
  ami                    = var.ubuntu_ami_id
  instance_type          = var.controller_instance_type
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.controller.id]

  key_name                    = var.key_pair_name
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/userdata/controller.sh", {
    mongodb_hosts = join("\n", [
      for index, instance in aws_instance.mongodb :
      "mongodb${index + 1} ansible_host=${instance.private_ip}"
    ])
  })

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
    Name    = "Ansible Controller"
    Project = var.project_name
    Role    = "controller"
  }
}

# =========================================
# 2. CREATE 3 MONGODB SERVERS
# =========================================

resource "aws_instance" "mongodb" {
  count = var.mongodb_count

  ami                    = var.ubuntu_ami_id
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
    Name    = "MongoDB-${format("%02d", count.index + 1)}"
    Project = var.project_name
    Role    = "mongodb"
  }
}

# =========================================
# 3. GENERATE LOCAL ANSIBLE INVENTORY
# =========================================

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/../ansible/inventory.ini"

  content = templatefile("${path.module}/userdata/inventory.ini.tftpl", {
    mongodb_hosts = join("\n", [
      for index, instance in aws_instance.mongodb :
      "mongodb${index + 1} ansible_host=${instance.private_ip}"
    ])
  })

  depends_on = [aws_instance.mongodb]
}