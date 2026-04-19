# VPC
output "vpc_id" {
  value = aws_vpc.vpc.id
}

# 퍼블릭 서브넷 AZ-a
output "public_subnet1_a_id" {
  value = aws_subnet.public_subnet1_a.id
}

# 퍼블릭 서브넷 AZ-c
output "public_subnet1_c_id" {
  value = aws_subnet.public_subnet1_c.id
}

# 프라이빗 서브넷 AZ-a (WAS)
output "private_subnet1_a_id" {
  value = aws_subnet.private_subnet1_a.id
}

# 프라이빗 서브넷 AZ-c (WAS)
output "private_subnet1_c_id" {
  value = aws_subnet.private_subnet1_c.id
}

# 프라이빗 서브넷 AZ-a (RDS)
output "private_subnet2_a_id" {
  value = aws_subnet.private_subnet2_a.id
}

# 프라이빗 서브넷 AZ-c (RDS)
output "private_subnet2_c_id" {
  value = aws_subnet.private_subnet2_c.id
}

# NAT 보안 그룹 (리팩토링(레이어 분리) 과정에서 주석 처리): NAT 관련 리소스 /app 폴더로 이동
# output "nat_sg_id" {
#   value = aws_security_group.nat_sg.id
# }

output "private_a_rt_id" {
  value = aws_route_table.private_a_rt.id
}

output "private_c_rt_id" {
  value = aws_route_table.private_c_rt.id
}
