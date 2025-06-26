### cloud vars
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

variable "pvt_name_prefix" {
  type = string
  default = "private-"

}
variable "pvt_net_options" {
  type = map(object({
    v4_cidr_blocks = list(string)
    zone           = string
  }))
  default = {
    a = {
      v4_cidr_blocks = ["192.168.20.0/24"]
      zone           = "ru-central1-a"
    }
    b = {
      v4_cidr_blocks = ["192.168.40.0/24"]
      zone           = "ru-central1-b"
    }
    d = {
      v4_cidr_blocks = ["192.168.60.0/24"]
      zone           = "ru-central1-d"
    }
  }
}

variable "pub_name_prefix" {
  type = string
  default = "public-"

}

variable "pub_net_options" {
  type = map(object({
    v4_cidr_blocks = list(string)
    zone           = string
  }))
  default = {
    a = {
      v4_cidr_blocks = ["192.168.10.0/24"]
      zone           = "ru-central1-a"
    }
    b = {
      v4_cidr_blocks = ["192.168.30.0/24"]
      zone           = "ru-central1-b"
    }
    d = {
      v4_cidr_blocks = ["192.168.50.0/24"]
      zone           = "ru-central1-d"
    }
  }
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


### common vars

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

### compute vars

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


### MySQL
# cluster

variable "my_cluster_hosts" {
  type = map(string)
  default = {
    a = "ru-central1-a"
    b = "ru-central1-b"
    d = "ru-central1-d"
  }
}

variable "my_cluster_options" {
  type = object({
    name                = string
    environment         = string
    version             = string
    deletion_protection = bool
    resources           = object({
      disk_size          = number
      disk_type_id       = string
      resource_preset_id = string
    })
    maintenance_window = object({
      type = string
    })
    backup_window_start = object({
      hours   = number
      minutes = number
    })
    mysql_config = object({
      default_authentication_plugin = string
      sql_mode                      = string
      max_connections               = number
    })
  })
  default = {
    environment         = "PRESTABLE"
    name                = "netology-db"
    version             = "8.0"
    deletion_protection = true

    resources = {
      disk_size          = 10
      disk_type_id       = "network-ssd"
      resource_preset_id = "c3-c2-m4"
    }
    maintenance_window = {
      type = "ANYTIME"
    }
    backup_window_start = {
      hours   = 23
      minutes = 59
    }
    mysql_config = {
      sql_mode                      = "ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION"
      max_connections               = 100
      default_authentication_plugin = "MYSQL_NATIVE_PASSWORD"

    }
  }
}

# database
variable "db_name" {
  type = string
  default = "netology_db"
}

variable "db_user" {
  type = object({
    name     = string
    password = string

    permission = object({
      roles = list(string)
    })

    connection_limits = object({
      max_questions_per_hour   = number
      max_updates_per_hour     = number
      max_connections_per_hour = number
      max_user_connections     = number
    })

    global_permissions = list(string)
    authentication_plugin = string
  })

  default = {
    name     = "netology"
    password = "dbPassw0rd"

    permission = {
    #    database_name = yandex_mdb_mysql_database.mysql_database.name
    roles = ["ALL"]
    }

    connection_limits = {
    max_questions_per_hour = 1000
    max_updates_per_hour = 2000
    max_connections_per_hour = 3000
    max_user_connections     = 4000
    }

    global_permissions = ["PROCESS"]
    authentication_plugin = "MYSQL_NATIVE_PASSWORD"
  }
}

### K8S
# encryption key
variable "k8s_key_options" {
  type = object({
    name              = string
    description       = string
    default_algorithm = string
    rotation_period   = string
  })
  default = {
    name              = "k8s-key"
    description       = "Key for kuber cluster"
    default_algorithm = "AES_256"
    rotation_period   = "8760h"
  }
}

#servce account
variable "k8s_sa_options" {
  type = object({
    name        = string
    description = string
    roles       = list(string)
  })

  default = {
    name        = "k8s-sa"
    description = "Service account for Kubernetes cluster"
    roles       = [
      "k8s.clusters.agent",
      "vpc.publicAdmin",
      "container-registry.images.puller",
      "kms.keys.encrypterDecrypter",
      "editor"
    ]
  }
}

#cluster options

variable "k8s_cluster_options" {
  type = object({
    name        = string
    description = string
    master      = object({
      version   = string
      public_ip = bool
      region    = string
    })
  })
  default = {
    name        = "netology-cluster"
    description = "regional k8s cluster test"
    master      = {
      version   = "1.32"
      public_ip = true
      region    = "ru-central1"
    }
  }
}

#node group

variable "k8s_node_group_options" {
  type = object({
    name         = string
    description  = string
    version      = string
    scale_policy = object({
      min     = number
      initial = number
      max     = number
    })
  })
  default = {
    name         = "my-node-group"
    description  = "description"
    version      = "1.32"
    scale_policy = {
      min     = 3
      initial = 3
      max     = 6
    }
  }
}

#node template
variable "k8s_node_template" {
  type = object({
    platform_id = string
    resources = object({
      memory        = number
      cores         = number
      cores_fraction = number
    })
    boot_disk = object({
      type = string
      size = number
    })
    nat = bool
    preemptible = bool
    container_runtime = string
  })
  default = {
    platform_id = "standard-v1"
    resources = {
      memory        = 2
      cores         = 2
      cores_fraction = 5
    }
    boot_disk = {
      type = "network-ssd"
      size = 30
    }
    nat = true
    preemptible = true
    container_runtime = "containerd"
  }

}