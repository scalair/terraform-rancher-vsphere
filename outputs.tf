output "cluster_id" {
  value = rancher2_cluster.this.id
}

output "node_templates" {
  value = keys(rancher2_node_template.this)
}

output "node_pools" {
  value = keys(rancher2_node_pool.this)
}

output "admin_id" {
  value = rancher2_user.admin.id
}

output "admin_principal_ids" {
  value = rancher2_user.admin.principal_ids
}

output "users_id" {
  value = rancher2_user.user.*.id
}

output "users_principal_ids" {
  value = rancher2_user.user.*.principal_ids
}
