resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main_vpc.id
  tags = {
    Name = "private_route_table"
  }
}

resource "aws_route_table_association" "private_subnet_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}

