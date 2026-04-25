output "vpc_id" { # VPC
  value = aws_vpc.vpc.id
}

output "nat_subnet_a_id" { # 퍼블릭 서브넷 AZ-a (NAT)
  value = aws_subnet.nat_public_a.id
}

output "nat_subnet_c_id" { # 퍼블릭 서브넷 AZ-c (NAT)
  value = aws_subnet.nat_public_c.id
}

output "was_subnet_a_id" { # 프라이빗 서브넷 AZ-a (WAS)
  value = aws_subnet.was_private_a.id
}

output "was_subnet_c_id" { # 프라이빗 서브넷 AZ-c (WAS)
  value = aws_subnet.was_private_c.id
}

output "rds_subnet_a_id" { # 프라이빗 서브넷 AZ-a (RDS)
  value = aws_subnet.rds_private_a.id
}

output "rds_subnet_c_id" { # 프라이빗 서브넷 AZ-c (RDS)
  value = aws_subnet.rds_private_c.id
}

output "was_private_a_rt_id" { # 프라이빗 라우팅 테이블 AZ-a (WAS)
  value = aws_route_table.private_a_rt.id
}

output "was_private_c_rt_id" { # 프라이빗 라우팅 테이블 AZ-c (WAS)
  value = aws_route_table.private_c_rt.id
}
