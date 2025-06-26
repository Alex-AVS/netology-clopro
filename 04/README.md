# 04. Кластеры. Ресурсы под управлением облачных провайдеров

### 1. 
Создаём публичные и приватные [сети](src/network.tf): 

```terraform
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
```
Проверяем:

![tf](img/04-01-nets.png)

### 2. 
Создаём [кластер](src/db.tf) Mysql, пользователя и БД. 
        
Проверяем:

![tf](img/04-02-mysql-clust.png)

Хосты:

![tf](img/04-02-mysql-hosts.png)

База:

![tf](img/04-02-mysql-db.png)

### 3. Кластер kubernetes
[Создаём](src/security.tf) ключ шифрования, сервисный аккаунт и добавляем его в необходимые роли:

```terraform
resource "yandex_kms_symmetric_key" "k8s-key" {
  name              = var.k8s_key_options.name
  description       = var.k8s_key_options.description
  default_algorithm = var.k8s_key_options.default_algorithm
  rotation_period   = var.k8s_key_options.rotation_period
}

resource "yandex_iam_service_account" "k8s-sa" {
  name        = var.k8s_sa_options.name
  description = var.k8s_sa_options.description
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-sa-roles" {
  for_each  = toset(var.k8s_sa_options.roles)
  folder_id = var.folder_id
  role      = each.key
  member    = "serviceAccount:${yandex_iam_service_account.k8s-sa.id}"
}
```

Создаём [кластер](src/k8s.tf) и группу нод.

Проверяем:

![tf](img/04-03-k8s-cluster.png)

![tf](img/04-03-k8s-cluster-2.png)

![tf](img/04-03-k8s-nodes.png)

Подключаемся к kubectl:

![tf](img/04-03-k8s-kubectl.png)

Создаём [deployment](src/pma.yaml) с приложением phpMyAdmin.

![tf](img/04-04-pma-apply.png)

Подключаемся:

![tf](img/04-04-pma-connect.png)

Файлы конфигурации расположены в каталоге [src](src/)

