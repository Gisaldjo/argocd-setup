#!/bin/bash

# This script is used to setup the cloudlab hosts for the argocd setup
# For each host in ansible_hosts file, ssh into host

hosts=$(awk '{print $1}' ansible_hosts)

for host in $hosts
do
    if [ $host == $(hostname -f) ]; then
        continue
    fi
    echo "Setting up host: $host"
    scp /users/gp27/.ssh/id_ed25519 gp27@$host:/users/gp27/.ssh/id_ed25519
    ssh -A -o StrictHostKeyChecking=no $(whoami)@$host 'bash -s' < cloudlab_prereq.sh
done
