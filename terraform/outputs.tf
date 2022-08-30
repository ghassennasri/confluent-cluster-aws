output "zookeeper" {
  description = "The full output of the `kafka` module"
  value       = module.zookeeper
}
output "kafka" {
  description = "The full output of the `kafka` module"
  value       = module.kafka
}
output "resource-ids" {
  value = <<-EOT
all:
  vars:
    ansible_connection: ssh
    ansible_user: ubuntu
    ansible_become: true
    ansible_ssh_private_key_file: ~/.ssh/id_rsa
    validate_hosts: false
    confluent_common_repository_debian_release_version: focal
    #Enable JMX Exporter
    jmxexporter_enabled: true
    env: aws
ldap_server:
  hosts:  
    ${one(module.ldap_server[*].private_dns)}:
      ansible_host: ${one(module.ldap_server[*].public_dns)}
      ansible_user: centos
zookeeper:
  hosts:
    ${values(module.zookeeper)[0].private_dns}:
      ansible_host: ${values(module.zookeeper)[0].public_dns}
    ${values(module.zookeeper)[1].private_dns}:
      ansible_host: ${values(module.zookeeper)[1].public_dns}
    ${values(module.zookeeper)[2].private_dns}:
      ansible_host: ${values(module.zookeeper)[2].public_dns}
kafka_broker:
  hosts:
    ${values(module.kafka)[0].private_dns}:
      ansible_host: ${values(module.kafka)[0].public_dns}
      kafka_broker_custom_properties:
        broker.rack: eu-west-3a
    ${values(module.kafka)[1].private_dns}:
      ansible_host: ${values(module.kafka)[1].public_dns}
      kafka_broker_custom_properties:
        broker.rack: eu-west-3b
    ${values(module.kafka)[2].private_dns}:
      ansible_host: ${values(module.kafka)[2].public_dns}
      kafka_broker_custom_properties:
        broker.rack: eu-west-3c
schema_registry:
  hosts:
    ${module.schema_regitry.private_dns}:
      ansible_host: ${module.schema_regitry.public_dns}
kafka_rest:
  hosts:
    ${module.kafka_rest.private_dns}:
      ansible_host: ${module.kafka_rest.public_dns}
ksql:
  hosts:
    ${values(module.ksql)[0].private_dns}:
      ansible_host: ${values(module.ksql)[0].public_dns}
    ${values(module.ksql)[1].private_dns}:
      ansible_host: ${values(module.ksql)[1].public_dns}
kafka_connect:
  hosts:
    ${module.kafka_connect.private_dns}:
      ansible_host: ${module.kafka_connect.public_dns}
control_center:
  hosts:
    ${module.control_center.private_dns}:
      ansible_host: ${module.control_center.public_dns}
 EOT

  #sensitive = true
}