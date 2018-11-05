data "template_file" "single_node_userdata_script" {
  template = "${file("${path.module}/../templates/user_data.sh")}"

  vars {
    cloud_provider          = "aws"
    security_groups         = "${aws_security_group.broker_security_group.id}"
    availability_zones      = "${join(",", coalescelist(var.availability_zones, data.aws_availability_zones.available.names))}"
    zookeeper               = "true"
    broker                  = "true"
  }
}

resource "aws_launch_configuration" "single_node" {
  // Only create if it's a single-node configuration
  count = "${var.zookeeper_count == "0" && var.broker_count == "0" ? "1" : "0"}"

  name_prefix = "kafka-${var.kafka_cluster}-single-node"
  image_id = "${data.aws_ami.kafka.id}"
  instance_type = "${var.zookeeper_instance_type}"
  security_groups = ["${aws_security_group.broker_security_group.id}","${aws_security_group.zookeeper_security_group.id}"]
  associate_public_ip_address = "${var.public_facing}"
  iam_instance_profile = "${aws_iam_instance_profile.kafka.id}"
  user_data = "${data.template_file.single_node_userdata_script.rendered}"
  key_name = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "single_node" {
  // Only create if it's a single-node configuration
  count = "${var.zookeeper_count == "0" && var.broker_count == "0" ? "1" : "0"}"

  name = "kafka-${var.kafka_cluster}-single-node"
  min_size = "0"
  max_size = "1"
  desired_capacity = "${var.zookeeper_count == "0" && var.broker_count == "0" ? "1" : "0"}"
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

  lifecycle {
    create_before_destroy = true
  }
}
