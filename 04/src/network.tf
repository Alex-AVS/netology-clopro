resource "yandex_vpc_network" "netology" {
  name = var.vpc_name
}
# Public subnets
resource "yandex_vpc_subnet" "public-networks" {
  for_each       = var.pub_net_options
  name           = "${var.pub_name_prefix}${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = each.value.v4_cidr_blocks
}

# Private subnets
resource "yandex_vpc_subnet" "private-networks" {
  for_each       = var.pvt_net_options
  name           = "${var.pvt_name_prefix}${each.key}"
  zone           = each.value.zone
  network_id     = yandex_vpc_network.netology.id
  v4_cidr_blocks = each.value.v4_cidr_blocks
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
