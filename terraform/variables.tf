variable "region" {
  description = "region where the confluent kafka cluster is provionned"
  type        = string
  default     = "eu-west-3"
}
variable "key_name" {
  description = "AWS key_name"
  type        = string
  default = "gnasri"
}
variable "create_ldap" {
  description = "switch indicating wether to create ldap"
  type        = bool
  default = "false"
}
variable "kcardinality" {
  description = "How many kafka brokers"
  type        = number
  default = 1
}
variable "zcardinality" {
  description = "How many zookeepers"
  type        = number
  default = 1
}
variable "cksql" {
  description = "How many ksql"
  type        = number
  default = 1
}

variable "vpc_cidr" {
    type = map
    default = {
        development     = "10.4"
        qa              = "10.5"
        staging         = "10.6"
        production      = "10.7"
    }
}

locals {
    private_subnets         = [
        "${lookup(var.vpc_cidr, var.environment)}.1.0/24",
        "${lookup(var.vpc_cidr, var.environment)}.2.0/24",
        "${lookup(var.vpc_cidr, var.environment)}.3.0/24"
    ]

    public_subnets        = [
        "${lookup(var.vpc_cidr, var.environment)}.11.0/24",
        "${lookup(var.vpc_cidr, var.environment)}.12.0/24",
        "${lookup(var.vpc_cidr, var.environment)}.13.0/24"
    ]

}

variable "environment" {
    type = string
    description = "Options: development, qa, staging, production"
    default = "development"
}