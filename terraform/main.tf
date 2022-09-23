provider "aws" {
  region = "eu-west-3"
}

locals {
  vpc_cidr= "${lookup(var.vpc_cidr, var.environment)}.0.0/16"
  name   = "staging-kafka"
  region = var.region
  tags = {
    Owner       = "confluent user"
    Environment = "staging"
    Name        = "staging-kafka"
  }
  zookeeper_ensemble = [
    for i in range(0, var.zcardinality) :
    {
      instance_name="zk-${i}"
      instance_type     = "t3.large"
      availability_zone = element(module.vpc.azs, i)
      subnet_id         = element(module.vpc.public_subnets, i)
      root_block_device = [
        {
          volume_type = "gp2"
          delete_on_termination = false
          tags = {
            Name = "zk-${i}"
          }
        }
      ]
    }
  ]
    kafka_cluster = [
    for i in range(0, var.kcardinality) :
    {
      instance_name="kafka-${i}"
      instance_type     = "t3.large"
      availability_zone = element(module.vpc.azs, i)
      subnet_id         = element(module.vpc.public_subnets, i)
      root_block_device = [
        {
          volume_type = "gp2"
          delete_on_termination = false
          tags = {
            Name = "kafka-${i}"
          }
        }
      ]
      ebs_block_device=[
        {
          volume_type = "gp2"
          delete_on_termination = false
          device_name = "/data/kafka"
          tags = {
            Name = "kafka-${i}-data"
            volume_size=20
          }
        }
      ]
    }
  ]
}
   
module "ldap_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "ldap_server"
  count = var.create_ldap?1:0
  ami                    = data.aws_ami.centos7_linux.id
  instance_type          = "t3.large"
  availability_zone      = element(module.vpc.azs, 2)
  subnet_id              = element(module.vpc.public_subnets, 2)
  vpc_security_group_ids = [module.security_group_ldap.security_group_id]
   root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 10
      tags = {
        Name = "ldap_server-root-block"
      }
    }
  ]
  enable_volume_tags = false
  #user_data_base64 = base64encode("${file("./user-data.sh")}")
  key_name = data.aws_key_pair.my-key.key_name
  tags = {
    Owner       = "confluent user"
    Environment = "staging"
    Name        = "ldap"
  }
  
}
module "schema_regitry" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "schema_registry"

  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t3.large"
  availability_zone      = element(module.vpc.azs, 1)
  subnet_id              = element(module.vpc.public_subnets, 1)
  vpc_security_group_ids = [module.security_group_schema_registry.security_group_id]
   root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 10
      tags = {
        Name = "schema_registry-root-block"
      }
    }
  ]
  enable_volume_tags = false
  user_data_base64 = base64encode("${file("./user-data.sh")}")
  key_name = data.aws_key_pair.my-key.key_name
  tags = {
    Owner       = "confluent user"
    Environment = "staging"
    Name        = "schema_registry"
  }
  
}
module "kafka_rest" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "kafka_rest"

  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t3.large"
  availability_zone      = element(module.vpc.azs, 1)
  subnet_id              = element(module.vpc.public_subnets, 1)
  vpc_security_group_ids = [module.security_group_kafka_rest.security_group_id]

  enable_volume_tags = false

  user_data_base64 = base64encode("${file("./user-data.sh")}")
  key_name = data.aws_key_pair.my-key.key_name
  tags = {
    Owner       = "confluent user"
    Environment = "staging"
    Name        = "kafka_rest"
  }
  
}
module "ksql" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

 count=var.cksql

  name = "ksql-${count.index}"


  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t3.large"
  availability_zone      = element(module.vpc.azs, count.index)
  subnet_id              = element(module.vpc.public_subnets, count.index)
  vpc_security_group_ids = [module.security_group_ksql.security_group_id]

  enable_volume_tags = false
  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      throughput  = 200
      volume_size = 10
      tags = {
        Name = "ksql-${count.index}-root-block"
      }
    }
  ]
  user_data_base64 = base64encode("${file("./user-data.sh")}")
  key_name = data.aws_key_pair.my-key.key_name
  tags = {
    Owner       = "confluent user"
    Environment = "staging"
    Name        = "ksql"
  }
  
}
module "kafka_connect" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  name = "kafka_connect"
  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t3.large"
  availability_zone      = element(module.vpc.azs, 1)
  subnet_id              = element(module.vpc.public_subnets, 1)
  vpc_security_group_ids = [module.security_group_kafka_connect.security_group_id]

  enable_volume_tags = false
  user_data_base64 = base64encode("${file("./user-data.sh")}")
  key_name = data.aws_key_pair.my-key.key_name
  tags = {
    Owner       = "confluent user"
    Environment = "staging"
    Name        = "kafka_connect"
  }
  
}
module "control_center" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  name = "control_center"
  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = "t3.large"
  availability_zone      = element(module.vpc.azs, 1)
  subnet_id              = element(module.vpc.public_subnets, 1)
  vpc_security_group_ids = [module.security_group_control_center.security_group_id]

  enable_volume_tags = false
  user_data_base64 = base64encode("${file("./user-data.sh")}")
  key_name = data.aws_key_pair.my-key.key_name
  tags = {
    Owner       = "confluent user"
    Environment = "staging"
    Name        = "control_center"
  }
  
}
module "kafka" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  for_each = {for broker in local.kafka_cluster: broker.instance_name =>  broker}

  name = "${each.value.instance_name}"

  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = each.value.instance_type
  availability_zone      = each.value.availability_zone
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [module.security_group_kafka.security_group_id]

  enable_volume_tags = false
  root_block_device  = lookup(each.value, "root_block_device", [])
  user_data_base64 = base64encode("${file("./user-data.sh")}")
  key_name = data.aws_key_pair.my-key.key_name
  tags = {
    Owner       = "confluent user"
    Environment = "staging"
    Name        = "${each.key}"
  }
  
}
module "zookeeper" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"
  for_each = {for node in local.zookeeper_ensemble: node.instance_name =>  node}

  name = "${each.value.instance_name}"

  ami                    = data.aws_ami.ubuntu_linux.id
  instance_type          = each.value.instance_type
  availability_zone      = each.value.availability_zone
  subnet_id              = each.value.subnet_id
  vpc_security_group_ids = [module.security_group_zookeeper.security_group_id]

  enable_volume_tags = false
  root_block_device  = lookup(each.value, "root_block_device", [])
  user_data_base64 = base64encode("${file("./user-data.sh")}")
  key_name = data.aws_key_pair.my-key.key_name
  tags = {
    Owner       = "confluent user"
    Environment = "staging"
    Name        = "${each.key}"
  }
  
}
################################################################################
# VPC Module
################################################################################

module "vpc" {
  #count  = var.vpc_cidr != null ? 0 : 1
  
  source = "terraform-aws-modules/vpc/aws"

  name = local.name
  #cidr = "20.10.0.0/16" # 10.0.0.0/8 is reserved for EC2-Classic

  azs             = ["${local.region}a", "${local.region}b", "${local.region}c"]
  #public_subnets  = ["20.10.1.0/24", "20.10.2.0/24", "20.10.3.0/24"]
  #private_subnets = ["20.10.4.0/24", "20.10.5.0/24", "20.10.6.0/24"]
  cidr                 = local.vpc_cidr
  private_subnets      = local.private_subnets
  public_subnets       = local.public_subnets
  
  manage_default_network_acl = true
  default_network_acl_tags   = { Name = "${local.name}-default" }

  manage_default_route_table = true
  default_route_table_tags   = { Name = "${local.name}-default" }

  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.name}-default" }

  enable_dns_hostnames = true
  enable_dns_support   = true


  enable_nat_gateway = true
  single_nat_gateway = true


  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60

  tags = local.tags
}
module "security_group_ldap"{
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Security group for ldap server"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["${data.external.myipaddr.result.ip}/32","0.0.0.0/32"]
  ingress_rules       = ["ssh-tcp","ldap-tcp","ldaps-tcp"]
         
    ingress_with_cidr_blocks = [
       {
      from_port   = 389
      to_port     = 389
      protocol    = "tcp"
      description = "ldap"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 636
      to_port     = 636
      protocol    = "tcp"
      description = "ldaps"
      cidr_blocks = local.vpc_cidr
    }
  ]
  egress_rules        = ["all-all"]
   

  tags = local.tags
}
module "security_group_kafka" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["${data.external.myipaddr.result.ip}/32","0.0.0.0/32"]
  ingress_rules       = ["ssh-tcp","kafka-broker-tcp","kafka-broker-tls-tcp","kafka-jmx-exporter-tcp"]
         
    ingress_with_cidr_blocks = [
       {
      from_port   = 9091
      to_port     = 9091
      protocol    = "tcp"
      description = "Inter-broker listener"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 9092
      to_port     = 9092
      protocol    = "tcp"
      description = "kafka default external plaintext listener"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 8090
      to_port     = 8090
      protocol    = "tcp"
      description = "Metadata Service (MDS)/Confluent Server REST API"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 9094
      to_port     = 9094
      protocol    = "tcp"
      description = "kafka TLS listener"
      cidr_blocks = local.vpc_cidr
    },
     {
      from_port   = 11001
      to_port     = 11001
      protocol    = "tcp"
      description = "kafka JMX exporter"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 11002
      to_port     = 11002
      protocol    = "tcp"
      description = "kafka JMX exporter"
      cidr_blocks = local.vpc_cidr
    }
  ]
  egress_rules        = ["all-all"]
   

  tags = local.tags
  
}
module "security_group_schema_registry" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "sg_schema_registry"
  description = "Security group schema registry"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["${data.external.myipaddr.result.ip}/32","0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
    ingress_with_cidr_blocks = [
    {
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      description = "schema registry REST API"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      description = "schema registry REST API"
      cidr_blocks = "${data.external.myipaddr.result.ip}/32"
    },
    {
      from_port   = 2888
      to_port     = 2888
      protocol    = "tcp"
      description = "zookeeper-2888-tcp"
      cidr_blocks = local.vpc_cidr
    },
     {
      from_port   = 7772
      to_port     = 7772
      protocol    = "tcp"
      description = "Jolokia"
      cidr_blocks = local.vpc_cidr
    }
  ]
  egress_rules        = ["all-all"]
   

  tags = local.tags
  
}
module "security_group_kafka_rest" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "sg_rest_proxy"
  description = "Security group REST proxy"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["${data.external.myipaddr.result.ip}/32","0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
    ingress_with_cidr_blocks = [
    {
      from_port   = 8082
      to_port     = 8082
      protocol    = "tcp"
      description = "REST Proxy"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 8081
      to_port     = 8081
      protocol    = "tcp"
      description = "REST Proxy"
      cidr_blocks = "${data.external.myipaddr.result.ip}/32"
    }
  ]
  egress_rules        = ["all-all"]
   

  tags = local.tags
  
}
module "security_group_ksql" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "sg_ksql"
  description = "Security group KSQL"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["${data.external.myipaddr.result.ip}/32","0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
    ingress_with_cidr_blocks = [
    {
      from_port   = 8088
      to_port     = 8088
      protocol    = "tcp"
      description = "REST API"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 8088
      to_port     = 8088
      protocol    = "tcp"
      description = "REST API"
      cidr_blocks = "${data.external.myipaddr.result.ip}/32"
    },
     {
      from_port   = 7774
      to_port     = 7774
      protocol    = "tcp"
      description = "Jolokia"
      cidr_blocks = local.vpc_cidr
    }
  ]
  egress_rules        = ["all-all"]
   

  tags = local.tags
  
}
module "security_group_kafka_connect" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "sg_connect"
  description = "Security group kafka connect"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["${data.external.myipaddr.result.ip}/32","0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
    ingress_with_cidr_blocks = [
    {
      from_port   = 8083
      to_port     = 8083
      protocol    = "tcp"
      description = "REST API"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 8083
      to_port     = 8083
      protocol    = "tcp"
      description = "REST API"
      cidr_blocks = "${data.external.myipaddr.result.ip}/32"
    },
     {
      from_port   = 7773
      to_port     = 7773
      protocol    = "tcp"
      description = "Jolokia"
      cidr_blocks = local.vpc_cidr
    }
  ]
  egress_rules        = ["all-all"]
   

  tags = local.tags
  
}
module "security_group_control_center" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = "sg_control_center"
  description = "Security group control center"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["${data.external.myipaddr.result.ip}/32","0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp"]
    ingress_with_cidr_blocks = [
    {
      from_port   = 9021
      to_port     = 9021
      protocol    = "tcp"
      description = "REST API"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 9021
      to_port     = 9021
      protocol    = "tcp"
      description = "REST API"
      cidr_blocks = "${data.external.myipaddr.result.ip}/32"
    }
  ]
  egress_rules        = ["all-all"]
   

  tags = local.tags
  
}
module "security_group_zookeeper" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_cidr_blocks = ["${data.external.myipaddr.result.ip}/32","0.0.0.0/0"]
  ingress_rules       = ["ssh-tcp","zookeeper-2181-tcp","zookeeper-jmx-tcp"]
    ingress_with_cidr_blocks = [
    {
      from_port   = 2181
      to_port     = 2181
      protocol    = "tcp"
      description = "zookeeper console"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 2182
      to_port     = 2182
      protocol    = "tcp"
      description = "Client access via TLS"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 2888
      to_port     = 2888
      protocol    = "tcp"
      description = "zookeeper-2888-tcp"
      cidr_blocks = local.vpc_cidr
    },
     {
      from_port   = 3888
      to_port     = 3888
      protocol    = "tcp"
      description = "zookeeper console"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 7199
      to_port     = 7199
      protocol    = "tcp"
      description = "zookeeper JMX"
      cidr_blocks = local.vpc_cidr
    },
    {
      from_port   = 7770
      to_port     = 7770
      protocol    = "tcp"
      description = "Jolokia"
      cidr_blocks = local.vpc_cidr
    }
  ]
  egress_rules        = ["all-all"]
   

  tags = local.tags
  
}
data "aws_ami" "ubuntu_linux" {
  most_recent = true
  owners =[ "099720109477"]
  

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20220610"]
  }
}
data "aws_ami" "centos7_linux" {
  most_recent = true
  owners =[ "125523088429"]
  

  filter {
    name   = "name"
    values = ["CentOS 7.9.2009 x86_64"]
  }
}

resource "random_shuffle" "az" {
  input        = ["eu-west-3a", "eu-west-3c", "eu-west-3b"]
  result_count = 1
}
data "aws_key_pair" "my-key" {
  key_name           = var.key_name
  include_public_key = true

}
data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://ipinfo.io/json'"]
}

output "my_public_ip" {
  value = "${data.external.myipaddr.result.ip}"
}