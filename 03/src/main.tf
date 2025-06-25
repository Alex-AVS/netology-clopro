
resource "yandex_kms_symmetric_key" "bucket-key" {
  name              = "bucket-key"
  default_algorithm = "AES_256"
}

resource "yandex_storage_bucket" "test_bucket" {
  bucket = var.s3_bucket_name
  folder_id = var.folder_id
  anonymous_access_flags {
    read = var.s3_anon_read
    list = var.s3_anon_list
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = yandex_kms_symmetric_key.bucket-key.id
        sse_algorithm     = "aws:kms"
      }
    }
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

output "image_url" {
  value = "https://${yandex_storage_bucket.test_bucket.bucket_domain_name}/${yandex_storage_object.image_file.key}"
}