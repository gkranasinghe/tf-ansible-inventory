output "public_ips" {
  description = "The public ips of the instance"
 value = [
    for instance in module.ec2_instances : instance.public_ip
  ]
}

output "host_names" {
  description = "The host names of the instance"
 value = [
    for instance in module.ec2_instances : instance.tags_all.Name
  ]
}

output "ansible_inventory" {
  description = "ansible inventory file contents "
  value = local_file.inventory.content
}

