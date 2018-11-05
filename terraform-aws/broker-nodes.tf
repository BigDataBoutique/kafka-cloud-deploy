data "template_file" "broker_userdata_script" {
  template = "${file("${path.module}/../templates/user_data.sh")}"

  vars {
    cloud_provider          = "aws"
    security_groups         = "${aws_security_group.broker_security_group.id}"
    availability_zones      = "${join(",", coalescelist(var.availability_zones, data.aws_availability_zones.available.names))}"
    zookeeper               = "false"
    broker                  = "true"
  }
}

resource "aws_launch_configuration" "broker" {
  name_prefix = "kafka-${var.kafka_cluster}-broker"
  image_id = "${data.aws_ami.kafka.id}"
  instance_type = "${var.broker_instance_type}"
  security_groups = ["${concat(list(aws_security_group.broker_security_group.id), var.additional_security_groups)}"]
  associate_public_ip_address = false
  iam_instance_profile = "${aws_iam_instance_profile.kafka.id}"
  user_data = "${data.template_file.broker_userdata_script.rendered}"
  key_name = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "broker_nodes" {
  name = "kafka-${var.kafka_cluster}-broker-nodes"
  max_size = "${var.broker_count}"
  min_size = "${var.broker_count}"
  desired_capacity = "${var.broker_count}"
  default_cooldown = 30
  force_delete = true
  launch_configuration = "${aws_launch_configuration.broker.id}"

  vpc_zone_identifier = ["${data.aws_subnet_ids.selected.ids}"]

  depends_on = ["aws_autoscaling_group.zookeeper_nodes"]

  tag {
    key                 = "Name"
    value               = "${format("%s-broker", var.kafka_cluster)}"
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
    value = "broker"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}