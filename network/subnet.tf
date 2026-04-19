# 가용 영역-A 퍼블릭 서브넷(NAT)
resource "aws_subnet" "public_subnet1_a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block        = "10.0.1.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet1-AZ-a"
  }
}

# 가용 영역-A 프라이빗 서브넷(WAS)
resource "aws_subnet" "private_subnet1_a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block        = "10.0.11.0/24"

  tags = {
    Name = "Private-Subnet1-AZ-a"
  }
}

# 가용 영역-A 프라이빗 서브넷(RDS)
resource "aws_subnet" "private_subnet2_a" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2a"
  cidr_block        = "10.0.21.0/24"

  tags = {
    Name = "Private-Subnet2-AZ-a"
  }
}

# 가용 영역-C 퍼블릭 서브넷(NAT)
resource "aws_subnet" "public_subnet1_c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block        = "10.0.2.0/24"

  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Subnet1-AZ-c"
  }
}

# 가용 영역-C 프라이빗 서브넷(WAS)
resource "aws_subnet" "private_subnet1_c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block        = "10.0.12.0/24"

  tags = {
    Name = "Private-Subnet1-AZ-c"
  }
}

# 가용 영역-C 프라이빗 서브넷(RDS)
resource "aws_subnet" "private_subnet2_c" {
  vpc_id            = aws_vpc.vpc.id
  availability_zone = "ap-northeast-2c"
  cidr_block        = "10.0.22.0/24"

  tags = {
    Name = "Private-Subnet2-AZ-c"
  }
}
