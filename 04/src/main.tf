

# NAT instance for tests
#resource "yandex_compute_instance" "nat-vm" {
#  name = var.nat_vm_options.instance_name
#
#    hostname = var.nat_vm_options.instance_name
#    platform_id = var.common_vm_options.platform
#    boot_disk {
#
#      initialize_params {
#        image_id = var.nat_vm_options.image_id
#        size = var.common_vm_options.boot_disk_size
#      }
#    }
#
#    resources {
#      cores  = var.common_vm_options.cores
#      memory = var.common_vm_options.memory
#      core_fraction = var.common_vm_options.cores_fraction
#    }
#
#    scheduling_policy {
#      preemptible = var.common_vm_options.preemptible
#    }
#
#    network_interface {
#      subnet_id = yandex_vpc_subnet.public-networks["a"].id
#      ip_address = var.rt_gateway
#      nat       = var.nat_vm_options.net_nat
#    }
#
#    metadata = {
#      user-data          = data.template_file.cloudinit.rendered
#      serial-port-enable = var.common_vm_options.meta_serial-port-enable
#    }
#}
#
#data "template_file" "cloudinit" {
#  template = file("./cloud-init.yml")
#  vars = {
#    username        = var.vms_ssh_user
#    ssh_public_key  = local.vms_ssh_root_key
#
#  }
#}

# Output
#output "nat_vm_external_ip" {
#  value = yandex_compute_instance.nat-vm.network_interface.0.nat_ip_address
}
