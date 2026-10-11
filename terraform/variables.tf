# Project name
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "CIS-BenchMark-MongoDB"
}

# VPC network
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Public subnet
variable "public_subnet_cidr" {
  description = "CIDR block for public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

# Private subnet
variable "private_subnet_cidr" {
  description = "CIDR block for private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

# Ansible Controller instance type
variable "controller_instance_type" {
  description = "EC2 type for Ansible Controller"
  type        = string
  default     = "t3.small"
}

# MongoDB instance type
variable "mongodb_instance_type" {
  description = "EC2 type for MongoDB"
  type        = string
  default     = "t3.micro"
}

# Number of MongoDB servers
variable "mongodb_count" {
  description = "Number of MongoDB EC2 instances"
  type        = number
  default     = 3
}

# EBS volume size
variable "root_volume_size" {
  description = "Root volume size in GiB"
  type        = number
  default     = 20
}
# =========================================
# SSH KEY PAIR
# =========================================

variable "key_pair_name" {
  description = "Existing AWS EC2 Key Pair name"
  type        = string
}

# =========================================
# ADMINISTRATOR PUBLIC IP
# =========================================

variable "admin_ip_cidr" {
  description = "Administrator public IPv4 CIDR for SSH"
  type        = string
}