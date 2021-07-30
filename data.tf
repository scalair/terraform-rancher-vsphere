data "rancher2_project" "default" {
    cluster_id  = rancher2_cluster.this.id
    name        = "Default"
}

data "rancher2_project" "system" {
    cluster_id  = rancher2_cluster.this.id
    name        = "System"
}

data "rancher2_user" "users" {
    count       = length(var.users)

    username    = "${var.users[count.index].username}-${rancher2_cluster.this.name}"
}

data "rancher2_project" "projects" {
    for_each    = toset(flatten([ for uk,user in var.users: [ for pp in user.project_privileges: pp.project_name ] ]))

    cluster_id  = rancher2_cluster.this.id
    name        = each.value
}
