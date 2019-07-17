#output "private-servers" {
#  value = ["${aws_instance.private-server.*.public_ip}"]
#}

#output "public-servers" {
#  value = ["${aws_instance.public-server.*.public_ip}"]
#}

output "vpc_id" {
  value = aws_vpc.main-us-west.id
}

output "region" {
  value = var.region
}

