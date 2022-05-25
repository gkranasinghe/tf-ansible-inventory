[vm-web]
%{ for host,dns in vm_dnshost ~}
$(host) ansible_host=$(dns)
%{ endfor ~}