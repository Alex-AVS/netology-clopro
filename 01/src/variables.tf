###cloud vars
variable "token" {
  type        = string
  description = "OAuth-token; https://cloud.yandex.ru/docs/iam/concepts/authorization/oauth-token"
}

variable "cloud_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/cloud/get-id"
}

variable "folder_id" {
  type        = string
  description = "https://cloud.yandex.ru/docs/resource-manager/operations/folder/get-id"
}

variable "default_zone" {
  type        = string
  default     = "ru-central1-a"
  description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

### networks

variable "vpc_name" {
  type        = string
  default     = "netology"
  description = "VPC network&subnet name"
}

variable "pvt_cidr" {
  type        = list(string)
  default     = ["192.168.20.0/24"]
  description = "private subnet address"
}

variable "pvt_name" {
  type        = string
  default     = "private"
  description = "private subnet name"
}

variable "pub_cidr" {
  type        = list(string)
  default     = ["192.168.10.0/24"]
  description = "public subnet address"
}

variable "pub_name" {
  type        = string
  default     = "public"
  description = "public subnet name"
}

variable "rt_name" {
  type        = string
  default     = "netology-rt"
  description = "default route name"
}

variable "rt_prefix" {
  type        = string
  default     = "0.0.0.0/0"
  description = "default route prefix"
}

variable "rt_gateway" {
  type        = string
  default     = "192.168.10.254"
  description = "default route prefix"
}


###common vars

variable "vms_ssh_root_key" {
  type        = string
  default     = "your_ssh_ed25519_key"
  description = "ssh-keygen -t ed25519"
}

variable "vms_ssh_user" {
  type        = string
  default     = "ubuntu"
  description = "Username for SSH access to VMs."
}

###compute vars

variable "common_vm_options" {
  type = object({
    preemptible             = bool
    net_nat                 = bool
    platform                = string
    meta_serial-port-enable = number
    boot_disk_size          = number
    instance_name           = string
    instance_hostname       = string
    image_id                = string
    cores                   = number
    cores_fraction          = number
    memory                  = number
  })
  default = {
    preemptible             = true
    platform                = "standard-v1"
    instance_name           = "web-{instance.index}"
    instance_hostname       = "web-{instance.index}"
    boot_disk_size          = 10
    image_id                = "fd827b91d99psvq5fjit" #LAMP Ubuntu
    net_nat                 = true
    meta_serial-port-enable = 1
    cores                   = 2
    cores_fraction          = 5
    memory                  = 1
  }
  description = "VM Template Parameters"
}

variable "nat_vm_options" {
  type = object({
    instance_name   = string
    image_id        = string
    net_nat         = bool
  })
  default = {
    instance_name   = "nat-vm"
    image_id        = "fd80mrhj8fl2oe87o4e1" #Nat instance Ubuntu
    net_nat         = true

  }
  description = "NAT VM options"
}


variable "pub_vm_options" {
  type = object({
    instance_name   = string
    net_nat         = bool
  })
  default = {
    instance_name   = "public-vm"
    net_nat         = true
  }
  description = "public VM options"
}

variable "pvt_vm_options" {
  type = object({
    instance_name   = string
    net_nat         = bool

  })
  default = {
    instance_name   = "private-vm"
    net_nat         = false
  }
  description = "private VM options"
}


