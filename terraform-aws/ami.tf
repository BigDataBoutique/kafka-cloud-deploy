// Find the latest available AMI for Kafka
data "aws_ami" "kafka" {
  filter {
    name = "state"
    values = ["available"]
  }
  filter {
    name = "tag:ImageType"
    values = ["kafka-packer-image"]
  }
  most_recent = true
}