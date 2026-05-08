data "aws_subnet" "cvp_nodes" {
  count = var.cluster_size
  id    = var.aws_subnet
}