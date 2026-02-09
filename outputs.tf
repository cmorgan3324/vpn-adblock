output "vpc_id" {
  value = aws_vpc.this.id
}

output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "security_group_id" {
  value = aws_security_group.vpn_sg.id
}

output "public_subnet_az" {
  value = aws_subnet.public.availability_zone
}

output "instance_id" {
  value = aws_instance.vpn.id
}

output "instance_public_ip" {
  value = aws_instance.vpn.public_ip
}

output "instance_public_dns" {
  value = aws_instance.vpn.public_dns
}
