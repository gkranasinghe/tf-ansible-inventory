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

output "ansible_hosts" {
  description = "ansible inventory file contents "
  value = zipmap([ for instance in module.ec2_instances : instance.tags_all.Name], [ for instance in module.ec2_instances : instance.public_ip] )
}

