[vm-web]
%{ for name,ip in vm_web ~}
${name} ansible_host=${ip}
%{ endfor ~}
