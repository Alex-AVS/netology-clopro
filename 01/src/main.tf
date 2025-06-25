
resource "yandex_vpc_network" "netology" {
  name = var.vpc_name
}
# Public subnet
resource "yandex_vpc_subnet" "public" {
  name           = var.pub_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.pub_cidr

}
# Private subnet
resource "yandex_vpc_subnet" "private" {
  name           = var.pvt_name
  zone           = var.default_zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = var.pvt_cidr
  route_table_id = yandex_vpc_route_table.netology-rt.id
}

# Routing table
resource "yandex_vpc_route_table" "netology-rt" {
  name       = var.rt_name
  network_id = yandex_vpc_network.netology.id
  static_route {
    destination_prefix = var.rt_prefix
    next_hop_address   = var.rt_gateway
  }
}

# NAT instance
resource "yandex_compute_instance" "nat-vm" {
  name = var.nat_vm_options.instance_name

    hostname = var.nat_vm_options.instance_name
    platform_id = var.common_vm_options.platform
    boot_disk {

      initialize_params {
        image_id = var.nat_vm_options.image_id
        size = var.common_vm_options.boot_disk_size
      }
    }

    resources {
      cores  = var.common_vm_options.cores
      memory = var.common_vm_options.memory
      core_fraction = var.common_vm_options.cores_fraction
    }

    scheduling_policy {
      preemptible = var.common_vm_options.preemptible
    }

    network_interface {
      subnet_id = yandex_vpc_subnet.public.id
      ip_address = var.rt_gateway
      nat       = var.nat_vm_options.net_nat
    }

    metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = var.common_vm_options.meta_serial-port-enable
    }
}

resource "yandex_compute_instance" "public-vm" {
  name = var.pub_vm_options.instance_name

    hostname = var.pub_vm_options.instance_name
    platform_id = var.common_vm_options.platform
    boot_disk {

      initialize_params {
        image_id = var.common_vm_options.image_id
        size = var.common_vm_options.boot_disk_size
      }
    }

    resources {
      cores  = var.common_vm_options.cores
      memory = var.common_vm_options.memory
      core_fraction = var.common_vm_options.cores_fraction
    }

    scheduling_policy {
      preemptible = var.common_vm_options.preemptible
    }

    network_interface {
      subnet_id = yandex_vpc_subnet.public.id
      nat       = var.pub_vm_options.net_nat
    }

    metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = var.common_vm_options.meta_serial-port-enable
    }

}

resource "yandex_compute_instance" "private-vm" {
  name = var.pvt_vm_options.instance_name

    hostname = var.pvt_vm_options.instance_name
    platform_id = var.common_vm_options.platform
    boot_disk {

      initialize_params {
        image_id = var.common_vm_options.image_id
        size = var.common_vm_options.boot_disk_size
      }
    }

    resources {
      cores  = var.common_vm_options.cores
      memory = var.common_vm_options.memory
      core_fraction = var.common_vm_options.cores_fraction
    }

    scheduling_policy {
      preemptible = var.common_vm_options.preemptible
    }

    network_interface {
      subnet_id = yandex_vpc_subnet.private.id
      nat       = var.pvt_vm_options.net_nat
    }

    metadata = {
      user-data          = data.template_file.cloudinit.rendered
      serial-port-enable = var.common_vm_options.meta_serial-port-enable
    }

}

data "template_file" "cloudinit" {
  template = file("./cloud-init.yml")
  vars = {
    username        = var.vms_ssh_user
    ssh_public_key  = local.vms_ssh_root_key

  }
}

# Output
output "nat_vm_external_ip" {
  value = yandex_compute_instance.nat-vm.network_interface.0.nat_ip_address
}
output "public_vm_external_ip" {
  value = yandex_compute_instance.public-vm.network_interface.0.nat_ip_address
}
output "private_vm_ip" {
  value = yandex_compute_instance.private-vm.network_interface.0.ip_address
}