locals {
  ingest_addr = length(module.cvp_provision_nodes.cluster_node[*].network.public.address) > 1 ? "${join(":9910,", module.cvp_provision_nodes.cluster_node[*].network.public.address)}:9910" : "${module.cvp_provision_nodes.cluster_node[0].network.public.address}:9910"
}

output "cvp_cluster_nodes_ips" {
  value = module.cvp_provision_nodes.cluster_node[*].network.public.address
}
output "cvp_cluster_ssh_user" {
  value = module.cvp_provision_nodes.cluster_node[*].ssh.username
}
output "cvp_deviceadd_instructions" {
  value = "Provisioning complete. To add devices use the following TerminAttr configuration:\nexec /usr/bin/TerminAttr -ingestgrpcurl=${local.ingest_addr} -cvcompression=gzip -ingestauth=${module.cvp_provision_nodes.cvp_ingest_key} -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -ingestexclude=/Sysdb/cell/1/agent,/Sysdb/cell/2/agent -ingestvrf=default -taillogs"
}
#output "cluster_node_data" {
#  value = module.cvp_provision_nodes.cluster_node
#}