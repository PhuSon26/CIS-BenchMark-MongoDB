# =========================================
# 1. CONTROLLER PUBLIC IP
# =========================================

output "controller_public_ip" {
  description = "Public IP of Ansible Controller"
  value       = aws_instance.controller.public_ip
}


# =========================================
# 2. CONTROLLER PRIVATE IP
# =========================================

output "controller_private_ip" {
  description = "Private IP of Ansible Controller"
  value       = aws_instance.controller.private_ip
}


# =========================================
# 3. MONGODB PRIVATE IPS
# =========================================

output "mongodb_private_ips" {
  description = "Private IPs of MongoDB servers"
  value       = aws_instance.mongodb[*].private_ip
}


# =========================================
# 4. MONGODB PRIVATE DNS
# =========================================

output "mongodb_private_dns" {
  description = "Private DNS of MongoDB servers"
  value       = aws_instance.mongodb[*].private_dns
}