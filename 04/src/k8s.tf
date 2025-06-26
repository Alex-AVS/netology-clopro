resource "yandex_kubernetes_cluster" "my-cluster" {
  name        = var.k8s_cluster_options.name
  description = var.k8s_cluster_options.description
  network_id = yandex_vpc_network.netology.id

  service_account_id      = yandex_iam_service_account.k8s-sa.id
  node_service_account_id = yandex_iam_service_account.k8s-sa.id

  master {
    version   = var.k8s_cluster_options.master.version
    public_ip = var.k8s_cluster_options.master.public_ip

    regional {
      region = var.k8s_cluster_options.master.region

      dynamic "location" {
        for_each = var.pub_net_options
        content {
          zone = location.value.zone
          subnet_id = yandex_vpc_subnet.public-networks[location.key].id
        }
      }
    }
  }

  kms_provider {
    key_id = yandex_kms_symmetric_key.k8s-key.id
  }

  #HOW???
  #depends_on = yandex_resourcemanager_folder_iam_member.k8s-sa-roles
}

resource "yandex_kubernetes_node_group" "my-node-group" {
  cluster_id  = yandex_kubernetes_cluster.my-cluster.id
  name        = var.k8s_node_group_options.name
  description = var.k8s_node_group_options.description
  version     = var.k8s_node_group_options.version

  instance_template {
    platform_id = var.k8s_node_template.platform_id

    network_interface {
      nat = var.k8s_node_template.nat
      subnet_ids = [
        #TODO!!
        yandex_vpc_subnet.public-networks["a"].id
      ]
    }

    resources {
      memory        = var.k8s_node_template.resources.memory
      cores         = var.k8s_node_template.resources.cores
      core_fraction = var.k8s_node_template.resources.cores_fraction
    }

    boot_disk {
      type = var.k8s_node_template.boot_disk.type
      size = var.k8s_node_template.boot_disk.size
    }

    scheduling_policy {
      preemptible = var.k8s_node_template.preemptible
    }

    container_runtime {
      type = var.k8s_node_template.container_runtime
    }
  }

  scale_policy {
    auto_scale {
      min     = var.k8s_node_group_options.scale_policy.min
      initial = var.k8s_node_group_options.scale_policy.initial
      max     = var.k8s_node_group_options.scale_policy.max
    }
  }

  allocation_policy {
    location {
      #TODO!!!
      zone = var.pub_net_options.a.zone
    }
  }
}