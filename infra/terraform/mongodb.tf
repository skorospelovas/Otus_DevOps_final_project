resource "yandex_compute_instance" "srv-mongodb" {
  name     = "srv-mongodb"
  hostname = "srv-mongodb"
  zone     = var.zone_app
  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }


  resources {
    cores  = 4
    memory = 4
  }


  boot_disk {
    initialize_params {
      size     = 30
      type     = "network-hdd"
      image_id = var.mongodb_image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_yc_kuber.id
    nat       = false
  }

}


