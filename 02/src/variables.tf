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
variable "default_cidr" {
  type        = list(string)
  default     = ["10.0.1.0/24"]
  description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
  type        = string
  default     = "netology"
  description = "VPC network&subnet name"
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

variable "instance_template_options" {
  type = object({
    preemptible = bool
    net_nat = bool
    platform = string
    meta_serial-port-enable = number

    boot_disk_size = number
    instance_name  = string
    instance_hostname  = string
    image_id   = string
    cores = number
    cores_fraction = number
    memory = number
  })
  default = {
    preemptible = true
    platform       = "standard-v1"

    instance_name  = "web-{instance.index}"
    instance_hostname       = "web-{instance.index}"

    boot_disk_size = 10
    image_id   = "fd827b91d99psvq5fjit"
    net_nat      = true
    meta_serial-port-enable = 1
    cores = 2
    cores_fraction = 5
    memory = 1
  }
  description = "VM Template Parameters"
}

variable "instance_group_options" {
  type = object({
    name               = string
    sa_id              = string
    allocation_zones   = list(string)
    max_expansion      = number
    max_unavailable    = number
    scale_size         = number
    lb_target_group_name = string
  })
  default = {
    name               = "web-servers"
    sa_id            = "ajeco4sgj5tkch9j8q4n"
    allocation_zones   = ["ru-central1-a"]
    max_expansion      = 2
    max_unavailable    = 2
    scale_size         = 3
    lb_target_group_name = "web-nlb-tg"
  }
  description = "Instance group options"
}

variable "ig_healthcheck_options" {
  type = object({
    healthy_threshold = number
    unhealthy_threshold = number
    interval = number
    timeout = number
    http_path = string
    http_port = number
  })
  default = {
    healthy_threshold = 2
    unhealthy_threshold = 2
    interval = 2
    timeout = 1
    http_path = "/"
    http_port = 80
  }
  description = "Instance group healthcheck params"
}


variable "nlb_options" {
  type = object({
    hc_port = number
    hc_path = string
    external_port = number
    name = string

  })
  default = {
    name = "web-server-nlb"
    hc_port = 80
    hc_path = "/"
    external_port = 80
  }
  description = "LOad balancer options"
}


###storage vars

variable "s3_bucket_name" {
  type        = string
  default     = "alexsys-test-bucket"
  description = "bucket name to create"
}
variable "s3_anon_read" {
  type = bool
  default = true
}

variable "s3_anon_list" {
  type = bool
  default = true
}

variable "s3_file_key" {
  type        = string
  default     = "theimage.jpg"
}

variable "s3_file_path" {
  type        = string
  default     = "res/the_cat.jpg"
}
