#!/bin/bash
cd terraform
terraform plan -no-color > aws_resources.txt
terraform apply --auto-approve
terraform output -raw resource-ids > ../ansible/aws_inventory.yml
sleep 120
# for test purpose: using python virtual environment
# source ~/python-venv/ansible2.11/bin/activate
# Get the latest Confluent collection from Ansible Galaxy
ansible-galaxy install -r requirements.yml
export CP_ANSIBLE_PATH=~/.ansible/collections/ansible_collections/confluent/platform
export ANSIBLE_HOST_KEY_CHECKING=False
# cd $CP_ANSIBLE_PATH
ansible-playbook   $CP_ANSIBLE_PATH/playbooks/all.yml   -i ../ansible/aws_inventory.yml