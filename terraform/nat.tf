# =========================================
# 1. CREATE ELASTIC IP FOR NAT GATEWAY
# =========================================

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}


# =========================================
# 2. CREATE NAT GATEWAY
# =========================================

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public.id

  depends_on = [
    aws_internet_gateway.igw
  ]

  tags = {
    Name = "${var.project_name}-nat"
  }
}


# =========================================
# 3. CREATE PRIVATE ROUTE TABLE
# =========================================

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}


# =========================================
# 4. ASSOCIATE PRIVATE SUBNET
# =========================================

resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}