data "template_file" "single_node_userdata_script" {
  template = "${file("${path.module}/../templates/user_data.sh")}"

  vars {
    region                  = "${var.aws_region}"
    zookeeper               = "true"
    broker                  = "true"
    zookeeper_count         = "${var.zookeeper_count}"
  }
}

resource "aws_launch_configuration" "single_node" {
  name_prefix = "kafka-${var.kafka_cluster}-single-node"
  image_id = "${data.aws_ami.kafka.id}"
  instance_type = "${var.zookeeper_instance_type}"
  security_groups = ["${concat(list(
    aws_security_group.zookeeper_security_group.id,
    aws_security_group.broker_security_group.id), var.additional_security_groups)}"]
  associate_public_ip_address = "${var.public_facing}"
  iam_instance_profile = "${aws_iam_instance_profile.kafka.id}"
  user_data = "${data.template_file.single_node_userdata_script.rendered}"
  key_name = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "single_node" {
  name = "kafka-${var.kafka_cluster}-single-node"

  min_size         = "${var.separate_zookeeper == "false" ? var.broker_count : "0"}"
  max_size         = "${var.separate_zookeeper == "false" ? var.broker_count : "0"}"
  desired_capacity = "${var.separate_zookeeper == "false" ? var.broker_count : "0"}"

  default_cooldown = 30
  force_delete = true
  launch_configuration = "${aws_launch_configuration.single_node.id}"

  vpc_zone_identifier = ["${data.aws_subnet_ids.selected.ids}"]
  
  tag {
    key = "Name"
    value = "${format("%s-kafka", var.kafka_cluster)}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.environment}"
    propagate_at_launch = true
  }
  tag {
    key = "Cluster"
    value = "${var.environment}-${var.kafka_cluster}"
    propagate_at_launch = true
  }
  tag {
    key = "Role"
    value = "single-node"
    propagate_at_launch = true
  }
  tag {
    key = "HasZookeeper"
    value = "true"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
