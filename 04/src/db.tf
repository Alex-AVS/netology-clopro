resource "yandex_mdb_mysql_cluster" "netology-db" {
  environment = var.my_cluster_options.environment
  name        = var.my_cluster_options.name
  network_id  = yandex_vpc_network.netology.id
  version     = var.my_cluster_options.version
  deletion_protection = var.my_cluster_options.deletion_protection

  dynamic "host" {
    for_each = var.my_cluster_hosts
    content {
      zone = host.value
      subnet_id = yandex_vpc_subnet.private-networks[host.key].id
    }
  }

  resources {
    disk_size          = var.my_cluster_options.resources.disk_size
    disk_type_id       = var.my_cluster_options.resources.disk_type_id
    resource_preset_id = var.my_cluster_options.resources.resource_preset_id
  }
  maintenance_window {
    type = var.my_cluster_options.maintenance_window.type
  }
  backup_window_start {
    hours   = var.my_cluster_options.backup_window_start.hours
    minutes = var.my_cluster_options.backup_window_start.minutes
  }

  mysql_config = {
    default_authentication_plugin = var.my_cluster_options.mysql_config.default_authentication_plugin
    sql_mode = var.my_cluster_options.mysql_config.sql_mode
    max_connections = var.my_cluster_options.mysql_config.max_connections
  }

  ### DEPRECATED. TODO: remove. Left for syntax in pycharm
#  database {
#    name = ""
#  }
#  user {
#    name     = ""
#    password = ""
#  }
}

resource "yandex_mdb_mysql_database" "mysql_database" {
  cluster_id = yandex_mdb_mysql_cluster.netology-db.id
  name       = var.db_name
}

resource "yandex_mdb_mysql_user" "netology-db" {
  cluster_id = yandex_mdb_mysql_cluster.netology-db.id
  name       = var.db_user.name
  password   = var.db_user.password

  permission {
    database_name = yandex_mdb_mysql_database.mysql_database.name
    roles         = var.db_user.permission.roles
  }
  connection_limits {
    max_questions_per_hour   = var.db_user.connection_limits.max_questions_per_hour
    max_updates_per_hour     = var.db_user.connection_limits.max_updates_per_hour
    max_connections_per_hour = var.db_user.connection_limits.max_connections_per_hour
    max_user_connections     = var.db_user.connection_limits.max_user_connections
  }

  global_permissions = var.db_user.global_permissions
  authentication_plugin = var.db_user.authentication_plugin
}