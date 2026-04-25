resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support   = true # DNS 지원 활성화
  enable_dns_hostnames = true # DNS 호스트 이름 활성화

  tags = {
    Name = "guestbook-vpc"
  }
}

resource "aws_subnet" "nat_public_a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block        = "10.0.1.0/24"

  map_public_ip_on_launch = true # 퍼블릭 서브넷에 인스턴스 생성 시 자동으로 퍼블릭 IP 할당

  tags = {
    Name = "guestbook-nat-subnet-az-a"
  }
}

resource "aws_subnet" "nat_public_c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block        = "10.0.2.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "guestbook-nat-subnet-az-c"
  }
}

resource "aws_subnet" "was_private_a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block        = "10.0.11.0/24"

  tags = {
    Name = "guestbook-was-subnet-az-a"
  }
}

resource "aws_subnet" "was_private_c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block        = "10.0.12.0/24"

  tags = {
    Name = "guestbook-was-subnet-az-c"
  }
}

resource "aws_subnet" "rds_private_a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block        = "10.0.21.0/24"

  tags = {
    Name = "guestbook-rds-subnet-az-a"
  }
}

resource "aws_subnet" "rds_private_c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block        = "10.0.22.0/24"

  tags = {
    Name = "guestbook-rds-subnet-az-c"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "guestbook-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"                 # 모든 트래픽
    gateway_id = aws_internet_gateway.igw.id # 인터넷 게이트웨이(igw)와 연결
  }

  tags = {
    Name = "guestbook-public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc1" {
  subnet_id      = aws_subnet.nat_public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_assoc2" {
  subnet_id      = aws_subnet.nat_public_c.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_a_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "guestbook-was-private-rt-az-a"
  }
}

resource "aws_route_table_association" "private_rt_assoc1" {
  subnet_id      = aws_subnet.was_private_a.id
  route_table_id = aws_route_table.private_a_rt.id
}

resource "aws_route_table" "private_c_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "guestbook-was-private-rt-az-c"
  }
}

resource "aws_route_table_association" "private_rt_assoc2" {
  subnet_id      = aws_subnet.was_private_c.id
  route_table_id = aws_route_table.private_c_rt.id
}

resource "aws_route_table" "private_rds_rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "guestbook-rds-private-rt"
  }
}

resource "aws_route_table_association" "private_rds_rt_assoc1" {
  subnet_id      = aws_subnet.rds_private_a.id
  route_table_id = aws_route_table.private_rds_rt.id
}

resource "aws_route_table_association" "private_rds_rt_assoc2" {
  subnet_id      = aws_subnet.rds_private_c.id
  route_table_id = aws_route_table.private_rds_rt.id
}
