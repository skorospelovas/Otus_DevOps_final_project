variable cloud_id {

  description = "Cloud"
}
variable folder_id {
  description = "Folder"
}
variable zone {
  description = "Zone"
  # Значение по умолчанию
  default = "ru-central1-a"
}
variable public_key_path {

  # Описание переменной
  description = "Path to the public key used for ssh access"
}


variable subnet_id {
  description = "Subnet"
}
variable service_account_key_file {
  description = "key.json"
}
variable private_key_path {
  description = "ubuntu private key"
}
variable zone_app {
  description = "Zone app"
  default     = "ru-central1-a"
}
variable "k8s_version" {
  default = "1.19"
}

variable "v4_cidr" {
  default = "10.0.0.0/16"
}

variable "k8s_sa_account_id" {
  default = "ajemdbe7o57so6cavv3t"
}
variable "ssh_username" {
  description = "Nodes ssh username"
}

variable "ssh_key_file" {
  description = "path to ssh key file"
}

variable "mongodb_image_id" {
  description = "mongodb image id"

}
variable "gitlab_domain" {
  description = "gitlab.project.space."

}


