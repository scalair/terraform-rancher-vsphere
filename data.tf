data "rancher2_project" "default-csi" {
    count     = var.cluster_csi_support ? 1 : 0

    cluster_id = rancher2_cluster.nocsi.0.id
    name = "Default"
}

data "rancher2_project" "default-nocsi" {
    count     = var.cluster_csi_support ? 0 : 1

    cluster_id = rancher2_cluster.nocsi.0.id
    name = "Default"
}

data "rancher2_project" "system-csi" {
    count     = var.cluster_csi_support ? 1 : 0

    cluster_id = rancher2_cluster.nocsi.0.id
    name = "System"
}

data "rancher2_project" "system-nocsi" {
    count     = var.cluster_csi_support ? 0 : 1

    cluster_id = rancher2_cluster.nocsi.0.id
    name = "System"
}

data "rancher2_user" "users" {
    count       = length(var.users)

    username    = "${var.users[count.index].username}-${rancher2_cluster.nocsi.0.name}"
}

data "rancher2_project" "projects-nocsi" {
    for_each    = var.cluster_csi_support ? [] : toset(flatten([ for uk,user in var.users: [ for pp in user.project_privileges: pp.project_name ] ]))

    cluster_id  = rancher2_cluster.nocsi.0.id
    name        = each.value
}

data "rancher2_project" "projects-csi" {
    for_each    = var.cluster_csi_support ? toset(flatten([ for uk,user in var.users: [ for pp in user.project_privileges: pp.project_name ] ])) : []

    cluster_id  = rancher2_cluster.csi.0.id
    name        = each.value
}
