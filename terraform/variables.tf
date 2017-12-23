### MANDATORY ###
variable "es_cluster" {
  description = "Name of the elasticsearch cluster, used in node discovery"
  default  = "es-prod-cluster"
}

variable "aws_region" {
  default = "ap-southeast-1"
}


variable "vpc_id" {
  description = "VPC ID to create the Elasticsearch cluster in"
  type = "string"
  default = "vpc-308f4a54"
}

variable "availability_zones" {
  type = "list"
  description = "AWS region to launch servers; if not set the available zones will be detected automatically"
  default = ["ap-southeast-1a","ap-southeast-1b"]
}

# If cluster mode then make it value "true"
variable "cluster_mode" {
  default = "true"
}

variable "vpc_subnets_private" {
  type = "list"
  description = "vpc_subnet_private"
  default = ["subnet-addf74db","subnet-e74af383"]
}

variable "key_name" {
  description = "Key name to be used with the launched EC2 instances."
  default = "elasticsearch"
}

variable "environment" {
  default = "default"
}

variable "data_instance_type" {
  type = "string"
  default = "c4.large"
}

variable "singlenode_instance_type" {
  type = "string"
  default = "m4.large"
}

variable "master_instance_type" {
  type = "string"
  default = "m4.large"
}

variable "elasticsearch_volume_size" {
  type = "string"
  default = "100" # gb
}

variable "volume_name" {
  default = "/dev/xvdh"
}

variable "volume_encryption" {
  default = true
}

variable "elasticsearch_data_dir" {
  default = "/opt/elasticsearch/data"
}

variable "elasticsearch_logs_dir" {
  default = "/var/log/elasticsearch"
}

# cluster data node heap size 
variable "data_heap_size" {
  type = "string"
  default = "3g"
}


# default elasticsearch heap size
variable "singlenode_heap_size" {
  type = "string"
  default = "3g"
}

variable "master_heap_size" {
  type = "string"
  default = "2g"
}

variable "masters_count" {
  default = "0"
}

variable "datas_count" {
  default = "0"
}

variable "clients_count" {
  default = "0"
}

# whether or not to enable x-pack security on the cluster
variable "security_enabled" {
  default = "false"
}

# client nodes have nginx installed on them, these credentials are used for basic auth
variable "client_user" {
  default = "admin"
}
variable "client_pwd" {
  default = "changeme"
}

# the ability to add additional existing security groups.
variable "additional_security_groups" {
  default = ""
}
