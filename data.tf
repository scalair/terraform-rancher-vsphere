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
