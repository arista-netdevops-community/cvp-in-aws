output "cluster_nodes" {
  value = aws_instance.cvp_nodes
}
output "cluster_node_ips" {
  value = aws_eip.cvp_nodes
}