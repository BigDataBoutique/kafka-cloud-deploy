resource "aws_iam_role" "kafka" {
  name               = "${var.kafka_cluster}-kafka-discovery-role"
  assume_role_policy = "${file("${path.module}/../templates/ec2-role-trust-policy.json")}"
}

resource "aws_iam_role_policy" "kafka" {
  name     = "${var.kafka_cluster}-kafka-discovery-policy"
  policy   = "${file("${path.module}/../templates/ec2-allow-describe-instances.json")}"
  role     = "${aws_iam_role.kafka.id}"
}

resource "aws_iam_instance_profile" "kafka" {
  name = "${var.kafka_cluster}-kafka-discovery-profile"
  path = "/"
  role = "${aws_iam_role.kafka.name}"
}
