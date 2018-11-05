### MANDATORY ###
variable "kafka_cluster" {
  description = "Name of the kafka cluster"
  default = "test_kafka"
}

variable "aws_region" {
  type = "string"
  default = "us-east-1"
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

variable "separate_zookeeper" {
  description = "Whether or not Zookeepers and Kafka brokers should run on different nodes"
  default = "false"
}

variable "broker_count" {
  description = "Number of Kafka broker nodes. When separate_zookeeper is false, this is the number of total nodes created"
  default = "1"
}

variable "zookeeper_count" {
  description = "Number of Zookeeper nodes. Is only used when separate_zookeeper is true"
  default = "1"
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
