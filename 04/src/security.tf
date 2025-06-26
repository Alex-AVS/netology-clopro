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
