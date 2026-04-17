resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc1" {
  subnet_id      = aws_subnet.public_subnet1_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc2" {
  subnet_id      = aws_subnet.public_subnet1_c.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_was1_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "WAS1-rt"
  }
}

resource "aws_route_table" "private_was2_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "WAS2-rt"
  }
}

resource "aws_route_table_association" "private_rt_assoc1" {
  subnet_id      = aws_subnet.private_subnet1_a.id
  route_table_id = aws_route_table.private_was1_rt.id
}

resource "aws_route_table_association" "private_rt_assoc2" {
  subnet_id      = aws_subnet.private_subnet1_c.id
  route_table_id = aws_route_table.private_was2_rt.id
}

# WAS 라우팅 테이블의 라우팅 규칙 (NAT 인스턴스의 ENI로 전송)
resource "aws_route" "was_nat_route_a" {
  route_table_id         = aws_route_table.private_was1_rt.id
  destination_cidr_block = "0.0.0.0/0"

  # 패킷을 인스턴스 본체로 보내는 게 아니라, NAT Instance (AZ-a)의 ENI(네트워크 인터페이스=NIC)로 보낸다
  network_interface_id = aws_instance.guestbook_nat_instance_a.primary_network_interface_id
}

resource "aws_route" "was_nat_route_c" {
  route_table_id         = aws_route_table.private_was2_rt.id
  destination_cidr_block = "0.0.0.0/0"
  network_interface_id   = aws_instance.guestbook_nat_instance_c.primary_network_interface_id
}

resource "aws_route_table" "private_rds_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "RDS-rt"
  }
}

resource "aws_route_table_association" "private_rds_rt_assoc1" {
  subnet_id      = aws_subnet.private_subnet2_a.id
  route_table_id = aws_route_table.private_rds_rt.id
}

resource "aws_route_table_association" "private_rds_rt_assoc2" {
  subnet_id      = aws_subnet.private_subnet2_c.id
  route_table_id = aws_route_table.private_rds_rt.id
}
