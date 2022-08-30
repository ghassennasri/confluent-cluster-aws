#!/bin/bash
PROJECT_DIR=$(pwd)
create_unsecure_cluster(){
cd $PROJECT_DIR/terraform
terraform plan -no-color > aws_resources.txt
terraform apply --auto-approve
terraform output -raw resource-ids > $PROJECT_DIR/ansible/unsecure/aws_inventory.yml
#sleep and wait for aws stack to be provisionned
while [ $secs -gt 0 ]; do
   echo -ne "Waiting $secs s for AWS stack to be provisioned\033[0K\r"
   sleep 1
   : $((secs--))
done
# for test purpose: using python virtual environment
# source ~/python-venv/ansible2.11/bin/activate
# Get the latest Confluent collection from Ansible Galaxy
ansible-galaxy install -r $PROJECT_DIR/requirements.yml
export CP_ANSIBLE_PATH=~/.ansible/collections/ansible_collections/confluent/platform
export ANSIBLE_HOST_KEY_CHECKING=False
# cd $CP_ANSIBLE_PATH
ansible-playbook   $CP_ANSIBLE_PATH/playbooks/all.yml   -i $PROJECT_DIR/ansible/unsecure/aws_inventory.yml
}
create_secure_cluster(){
cd $PROJECT_DIR/terraform
terraform plan -no-color > aws_resources.txt
terraform apply --auto-approve
terraform output -raw resource-ids > $PROJECT_DIR/ansible/production/cluster/inventory.yml
secs=$((2 * 60))
#sleep and wait for aws stack to be provisionned
while [ $secs -gt 0 ]; do
   echo -ne "------ Waiting $secs s for AWS stack to be provisioned------------\033[0K\r"
   sleep 1
   : $((secs--))
done
# for test purpose: using python virtual environment
# source ~/python-venv/ansible2.11/bin/activate
# Get the latest Confluent collection from Ansible Galaxy
ansible-galaxy install -r $PROJECT_DIR/requirements.yml
export CP_ANSIBLE_PATH=~/.ansible/collections/ansible_collections/confluent/platform
export ANSIBLE_HOST_KEY_CHECKING=False
# cd $CP_ANSIBLE_PATH
cd $PROJECT_DIR/ansible/production/cluster
ansible all --ask-vault-pass  -m ping -i inventory.yml
ansible-playbook --ask-vault-pass     ../certs/cert-playbook.yml     -i inventory.yml
ansible-playbook --ask-vault-pass     ../ldap.yml     -i inventory.yml

ansible-playbook --ask-vault-pass \
    $CP_ANSIBLE_PATH/playbooks/all.yml \
> -i /home/ubuntu/projects/terraform/confluent-cluster/ansible/production/cluster/inventory.yml 
}
log_error() {
    local MSG="$1"
    printf "%s - [ERROR] %s\n" "$(date)" "$MSG" >&2
}
case "$1" in
    "") ;;
    create_unsecure_cluster) "$@"; exit;;
    create_secure_cluster) "$@"; exit;;
    log_error) "$@"; exit;;
    *) log_error "Unkown function: $1()"; exit 2;;
esac
