output "alb_dns" {
  value       = aws_lb.production-lb.dns_name
  description = "DNS name of alb"
}

output "vpc_id" {
  value       = aws_vpc.Production_vpc.id
  description = "VPC id of production vpc"
}

output "igw_id" {
  value       = [aws_internet_gateway.Production_igw.id]
  description = "Internet gateway"
}

output "ngw_id" {
  value       = [aws_nat_gateway.nat-gw.id]
  description = "NAT gateway"
}