output "cluster_id" {
  value = var.cluster_csi_support ? rancher2_cluster.csi.0.id : rancher2_cluster.nocsi.0.id
}

output "node_templates" {
  value = keys(rancher2_node_template.this)
}

output "node_pools" {
  value = var.cluster_csi_support ? keys(rancher2_node_pool.csi) : keys(rancher2_node_pool.nocsi)
}
