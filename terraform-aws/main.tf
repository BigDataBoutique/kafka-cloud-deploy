provider "aws" {
  region = "${var.aws_region}"
}

data "aws_availability_zones" "available" {}

##############################################################################
# Kafka
##############################################################################

resource "aws_security_group" "broker_security_group" {
  name = "kafka-${var.kafka_cluster}-broker-security-group"
  description = "Kafka ports with ssh"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.kafka_cluster}-broker"
    cluster = "${var.kafka_cluster}"
  }

  # ssh access from everywhere
  ingress {
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  # inter-cluster communication over 9092
  ingress {
    from_port         = 9092
    to_port           = 9092
    protocol          = "tcp"
    self              = true
  }

  # allow inter-cluster ping
  ingress {
    from_port         = 8
    to_port           = 0
    protocol          = "icmp"
    self              = true
  }

  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "zookeeper_security_group" {
  name = "kafka-${var.kafka_cluster}-zookeeper-security-group"
  description = "Zookeeper ports with ssh"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.kafka_cluster}-zookeeper"
    cluster = "${var.kafka_cluster}"
  }
  
  # ssh access from everywhere
  ingress {
    from_port         = 22
    to_port           = 22
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  # allow connections from brokers
  ingress {
    from_port         = 2181
    to_port           = 2181
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"] # TODO fix to only brokers IPs
  }

  # allow connections from other zookeepers in the cluster
  ingress {
    from_port         = 2888
    to_port           = 2888
    protocol          = "tcp"
    self              = true
  }

  # allow connections from other zookeepers in the cluster
  ingress {
    from_port         = 3888
    to_port           = 3888
    protocol          = "tcp"
    self              = true
  }
  
  # allow inter-cluster ping
  ingress {
    from_port         = 8
    to_port           = 0
    protocol          = "icmp"
    self              = true
  }

  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
}