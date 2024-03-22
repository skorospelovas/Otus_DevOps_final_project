resource "yandex_kubernetes_cluster" "k8s-cluster" {
  name        = "k8s-cluster"
  description = "test cluster"

  network_id = yandex_vpc_network.this.id

  master {
    version = var.k8s_version
    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.subnet_yc_kuber.id
    }

    public_ip = true


    maintenance_policy {
      auto_upgrade = true

      maintenance_window {
        start_time = "01:00"
        duration   = "3h"
      }
    }
  }

  service_account_id      = var.k8s_sa_account_id
  node_service_account_id = var.k8s_sa_account_id


  release_channel         = "RAPID"
  network_policy_provider = "CALICO"


}




resource "yandex_kubernetes_node_group" "k8s_node_group" {
  cluster_id  = yandex_kubernetes_cluster.k8s-cluster.id
  name        = "nodegroup"
  description = "test k8s_node_group"
  version     = var.k8s_version


  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = ["${yandex_vpc_subnet.subnet_yc_kuber.id}"]
    }

    resources {
      memory = 8
      cores  = 4
    }

    boot_disk {
      type = "network-ssd"
      size = 64
    }
    metadata = {
      ssh-keys = "${var.ssh_username}:${data.local_file.ssh_key.content}"
    }


    scheduling_policy {
      preemptible = false
    }


  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }

  maintenance_policy {
    auto_upgrade = true
    auto_repair  = true

    maintenance_window {
      day        = "monday"
      start_time = "15:00"
      duration   = "3h"
    }

    maintenance_window {
      day        = "friday"
      start_time = "10:00"
      duration   = "4h30m"
    }


  }

  depends_on = [data.local_file.ssh_key]
}

data "local_file" "ssh_key" {
  filename = var.ssh_key_file
}

resource "null_resource" "kube-context" {
  provisioner "local-exec" {
    command = "yc managed-kubernetes cluster get-credentials k8s-cluster --external --force"

  }
  depends_on = [yandex_kubernetes_node_group.k8s_node_group]
}




