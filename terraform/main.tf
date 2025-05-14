terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
    local = {
      source = "hashicorp/local"
    }
  }
}

provider "yandex" {
  token     = var.yc_token
  cloud_id  = var.yc_cloud_id
  folder_id = var.yc_folder_id
  zone      = var.yc_zone
}

resource "yandex_vpc_network" "swarm_network" {
  name = "swarm-network"
}

resource "yandex_vpc_subnet" "swarm_subnet" {
  name           = "swarm-subnet"
  zone           = var.yc_zone
  network_id     = yandex_vpc_network.swarm_network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "swarm_manager" {
  name        = "swarm-manager"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 22.04 LTS
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.swarm_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

}

resource "yandex_compute_instance" "swarm_workers" {
  count       = var.worker_count
  name        = "swarm-worker-${count.index + 1}"
  platform_id = "standard-v3"
  zone        = var.yc_zone

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8vmcue7aajpmeo39kk" # Ubuntu 22.04 LTS
      size     = 20
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.swarm_subnet.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file(var.ssh_public_key_path)}"
  }

}

resource "yandex_vpc_security_group" "swarm_sg" {
  name        = "swarm-security-group"
  network_id  = yandex_vpc_network.swarm_network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Docker Swarm"
    port           = 2377
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "Docker API"
    port           = 2376
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTP"
    port           = 80
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    description    = "HTTPS"
    port           = 443
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    description    = "Outbound traffic"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}
