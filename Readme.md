# Provision Confluent cluster on AWS using Terraform and Ansible 
## Prequisites
- Terraform >v1.2.7 installed. Please refer to https://learn.hashicorp.com/tutorials/terraform/install-cli
- Ansible 2.11 installed. Please refer to https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

**Commands :**
### Unsecure cluster
```sh
cd [main project directory]
./provision-cluster.sh  create_unsecure_cluster
```
### secure cluster
```sh
cd [main project directory]
./provision-cluster.sh  create_secure_cluster
```
**References :**
https://registry.terraform.io/namespaces/terraform-aws-modules
https://docs.confluent.io/ansible/current/overview.html