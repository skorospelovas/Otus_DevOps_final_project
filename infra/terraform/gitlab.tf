data "yandex_compute_image" "image" {
  family = "ubuntu-2204-lts"
}


resource "yandex_vpc_address" "gitlabIP" {
  name = "GitlabIP"

  external_ipv4_address {
    zone_id = var.zone
  }
}


resource "yandex_dns_zone" "zone1" {
  name        = "project-zone"
  description = "desc"
  zone        = "project.space."
  public      = true

}

resource "yandex_dns_recordset" "gitlab" {
  zone_id = yandex_dns_zone.zone1.id
  name    = var.gitlab_domain
  type    = "A"
  ttl     = 60
  data    = [yandex_vpc_address.gitlabIP.external_ipv4_address.0.address]
}



resource "yandex_compute_instance" "srv-gitlab" {
  name     = "srv-gitlab"
  hostname = "srv-gitlab"
  zone     = var.zone_app
  metadata = {
    ssh-keys = "ubuntu:${file(var.public_key_path)}"
  }


  resources {
    cores  = 8
    memory = 8
  }


  boot_disk {
    initialize_params {
      size     = 30
      type     = "network-hdd"
      image_id = data.yandex_compute_image.image.id
    }
  }


  network_interface {

    subnet_id      = yandex_vpc_subnet.subnet_yc_kuber.id
    nat            = true
    nat_ip_address = yandex_vpc_address.gitlabIP.external_ipv4_address.0.address

  }

  #waiting for machine start
  provisioner "remote-exec" {
    inline = [
    "echo"]
  }

  connection {
    type        = "ssh"
    host        = self.network_interface[0].nat_ip_address
    user        = "ubuntu"
    agent       = false
    private_key = file(var.private_key_path)
  }


  provisioner "local-exec" {
    command     = "ansible-playbook playbooks/site.yml"
    working_dir = "../ansible"
  }
}
