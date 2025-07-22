output "nat_instance_id" {
  value = aws_instance.nat.id
}

output "nat_instance_public_ip" {
  value = aws_instance.nat.public_ip
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "app_private_ip" {
  value = aws_instance.app.private_ip
}
