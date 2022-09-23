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
%{ for l in module.ldap_server }
ldap_server:
  hosts:  
    ${one(module.ldap_server[*].private_dns)}:
      ansible_host: ${one(module.ldap_server[*].public_dns)}
      ansible_user: centos
%{ endfor }
zookeeper:
  hosts:
    %{ for z in values(module.zookeeper) }
    ${z.private_dns}:
      ansible_host: ${z.public_dns}
    %{ endfor }
kafka_broker:
  hosts:
    %{for k in values(module.kafka) }
    ${k.private_dns}:
      ansible_host: ${k.public_dns}
      kafka_broker_custom_properties:
        broker.rack: ${format("%s%x",var.region,index(values(module.kafka),k)+10)}
    %{ endfor }
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
    %{ for k in module.ksql }
    ${k.private_dns}:
      ansible_host: ${k.public_dns}
      %{ endfor }
kafka_connect:
  hosts:
    ${module.kafka_connect.private_dns}:
      ansible_host: ${module.kafka_connect.public_dns}
control_center:
  hosts:
    ${module.control_center.private_dns}:
      ansible_host: ${module.control_center.public_dns}
    EOT
}