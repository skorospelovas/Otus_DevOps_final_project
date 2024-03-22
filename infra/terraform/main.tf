terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {

  service_account_key_file = var.service_account_key_file
  cloud_id                 = var.cloud_id
  folder_id                = var.folder_id
  zone                     = var.zone
}


resource "yandex_vpc_network" "this" {
  name = "1net"
}


resource "yandex_vpc_subnet" "subnet_yc_kuber" {
  name           = "Project"
  network_id     = yandex_vpc_network.this.id
  zone           = var.zone
  v4_cidr_blocks = [var.v4_cidr]
}





