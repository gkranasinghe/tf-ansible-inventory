output "public_ips" {
  description = "The ID of the instance"
 value = [
    for instance in module.ec2_instances : instance.public_ip
  ]
}

output "host_names" {
  description = "The ID of the instance"
 value = [
    for instance in module.ec2_instances : instance.tags_all.Name
  ]
}

output "vm_web" {
  description = "vm_web"
  value = zipmap([ for instance in module.ec2_instances : instance.tags_all.Name], [ for instance in module.ec2_instances : instance.public_ip] )
}

