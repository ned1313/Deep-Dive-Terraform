#!/bin/bash
sudo yum update
sudo yum install git -y
sudo amazon-linux-extras install ansible2 -y
sudo mkdir /var/ansible_playbooks
sudo git clone ${playbook_repository} /var/ansible_playbooks
ansible-playbook /var/ansible_playbooks/playbook.yml -i /var/ansible_playbooks/hosts