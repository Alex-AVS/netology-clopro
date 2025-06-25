resource "yandex_storage_bucket" "test_bucket" {
  bucket = var.s3_bucket_name
  folder_id = var.folder_id
  anonymous_access_flags {
    read = var.s3_anon_read
    list = var.s3_anon_list
  }
}

resource "yandex_storage_object" "image_file" {
  depends_on = [yandex_storage_bucket.test_bucket]
  bucket = var.s3_bucket_name
  key    = var.s3_file_key
  source = var.s3_file_path

}

resource "yandex_vpc_network" "netology" {
  name = var.vpc_name
}
resource "yandex_vpc_subnet" "netology" {
  name           = var.vpc_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.default_cidr
}

resource "yandex_compute_instance_group" "web-servers" {
  name = var.instance_group_options.name
  service_account_id = var.instance_group_options.sa_id

  allocation_policy {
    zones = var.instance_group_options.allocation_zones
  }
  scale_policy {
    fixed_scale {
      size = var.instance_group_options.scale_size
    }
  }
  deploy_policy {
    max_expansion   = var.instance_group_options.max_expansion
    max_unavailable = var.instance_group_options.max_unavailable
  }
  instance_template {
    name = var.instance_template_options.instance_name
    hostname = var.instance_template_options.instance_hostname
    platform_id = var.instance_template_options.platform
    boot_disk {

      initialize_params {
        image_id = var.instance_template_options.image_id
        size = var.instance_template_options.boot_disk_size
      }
    }

    resources {
      cores  = var.instance_template_options.cores
      memory = var.instance_template_options.memory
      core_fraction = var.instance_template_options.cores_fraction
    }

    scheduling_policy {
      preemptible = var.instance_template_options.preemptible
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.netology.id]
      nat       = var.instance_template_options.net_nat
    }

    metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = var.instance_template_options.meta_serial-port-enable
    }
  }
  health_check {
    healthy_threshold = var.ig_healthcheck_options.healthy_threshold
    unhealthy_threshold = var.ig_healthcheck_options.unhealthy_threshold
    interval = var.ig_healthcheck_options.interval
    timeout = var.ig_healthcheck_options.timeout
    http_options {
      path = var.ig_healthcheck_options.http_path
      port = var.ig_healthcheck_options.http_port
    }
  }

  load_balancer {
    target_group_name = var.instance_group_options.lb_target_group_name
  }

}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    username        = var.vms_ssh_user
    ssh_public_key  = local.vms_ssh_root_key
    s3_bucket_name  = var.s3_bucket_name
    s3_file_key     = var.s3_file_key
  }
}

resource "yandex_lb_network_load_balancer" "web-server-nlb" {
  name = var.nlb_options.name
  type = "external"
  listener {
    name = "public-service"
    port = var.nlb_options.external_port

    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_compute_instance_group.web-servers.load_balancer.0.target_group_id

    healthcheck {
      name = "internal-app-port"
      http_options {
        port = var.nlb_options.hc_port
        path = var.nlb_options.hc_path
      }
    }
  }
}