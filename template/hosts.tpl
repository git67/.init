[bootstrapnode]
${HOSTN}

[all:vars]
ansible_ssh_common_args='-o UserKnownHostsFile=/dev/null -o GSSAPIAuthentication=no -o StrictHostKeyChecking=no'
