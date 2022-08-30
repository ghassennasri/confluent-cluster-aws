variable "region" {
  description = "region where the confluent kafka cluster is provionned"
  type        = string
  default     = "eu-west-3"
}
variable "vpc_cidr" {
  description = "CIDR of the VPC where kafka cluster is provionned"
  type        = string
  default     = null
}
variable "key_name" {
  description = "AWS key_name"
  type        = string
  default = "gnasri"
}
variable "create_ldap" {
  description = "switch indicating wether to create ldap"
  type        = bool
  default = "true"
}
