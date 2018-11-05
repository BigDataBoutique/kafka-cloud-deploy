### MANDATORY ###
variable "kafka_cluster" {
  description = "Name of the kafka cluster"
  default = "test_kafka_cluster"
}

variable "aws_region" {
  type = "string"
}

variable "vpc_id" {
  description = "VPC ID to create the Kafka cluster in"
  type = "string"
}

variable "availability_zones" {
  type = "list"
  description = "AWS region to launch servers; if not set the available zones will be detected automatically"
  default = []
}

variable "key_name" {
  description = "Key name to be used with the launched EC2 instances."
  default = "kafka"
}

variable "environment" {
  default = "default"
}

variable "broker_instance_type" {
  type = "string"
  default = "t2.micro"
}

variable "zookeeper_instance_type" {
  type = "string"
  default = "t2.micro"
}

variable "broker_count" {
  default = "0"
}

variable "zookeeper_count" {
  default = "0"
}

variable "public_facing" {
  description = "Whether or not the created cluster should be accessible from the public internet"
  type = "string"
  default = "true"
}

# the ability to add additional existing security groups
variable "additional_security_groups" {
  type = "list"
  default = []
}
