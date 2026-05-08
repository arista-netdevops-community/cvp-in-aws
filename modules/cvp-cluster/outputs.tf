output "nodes" {
  value = aws_instance.cvp_nodes
}
output "node_ips" {
  value = aws_eip.cvp_nodes
}
output "subnets" {
  value = data.aws_subnet.cvp_nodes
}
output "data_disk" {
  value = aws_ebs_volume.cvp_nodes
}
output "data_disk_attachment" {
  value = aws_volume_attachment.cvp_nodes
}