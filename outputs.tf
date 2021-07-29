output "cluster_id" {
  value = var.cluster_csi_support ? rancher2_cluster.csi.0.id : rancher2_cluster.nocsi.0.id
}

output "node_templates" {
  value = keys(rancher2_node_template.this)
}

output "node_pools" {
  value = var.cluster_csi_support ? keys(rancher2_node_pool.csi) : keys(rancher2_node_pool.nocsi)
}

output "admin_id" {
  value = var.cluster_csi_support ? rancher2_user.admin-csi.0.id : rancher2_user.admin-nocsi.0.id
}

output "admin_principal_ids" {
  value = var.cluster_csi_support ? rancher2_user.admin-csi.0.principal_ids : rancher2_user.admin-nocsi.0.principal_ids
}

output "users_id" {
  value = var.cluster_csi_support ? rancher2_user.user-csi.*.id : rancher2_user.user-nocsi.*.id
}

output "users_principal_ids" {
  value = var.cluster_csi_support ? rancher2_user.user-csi.*.principal_ids : rancher2_user.user-nocsi.*.principal_ids
}
