output "manager_public_ip" {
  value = yandex_compute_instance.swarm_manager.network_interface.0.nat_ip_address
}

output "worker_public_ips" {
  value = yandex_compute_instance.swarm_workers[*].network_interface.0.nat_ip_address
}
