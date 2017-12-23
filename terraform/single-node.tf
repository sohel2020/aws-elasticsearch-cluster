data "template_file" "single_node_userdata_script" {
  template = "${file("${path.root}/../templates/user_data.sh")}"
  count = "${var.cluster_mode == "false" ? "1" : "0"}"

  vars {
    cloud_provider          = "aws"
    volume_name             = "${var.volume_name}"
    elasticsearch_data_dir  = "${var.elasticsearch_data_dir}"
    elasticsearch_logs_dir  = "${var.elasticsearch_logs_dir}"
    heap_size               = "${var.singlenode_heap_size}"
    es_cluster              = "${var.es_cluster}"
    es_environment          = "${var.environment}-${var.es_cluster}"
    security_groups         = "${aws_security_group.elasticsearch_single_node_security_group.id}"
    aws_region              = "${var.aws_region}"
    availability_zones      = "${join(",", coalescelist(var.availability_zones, data.aws_availability_zones.available.names))}"
    minimum_master_nodes    = "${format("%d", var.masters_count / 2 + 1)}"
    master                  = "true"
    data                    = "true"
    http_enabled            = "true"
    security_enabled        = "${var.security_enabled}"
    client_user             = "${var.client_user}"
    client_pwd              = "${var.client_pwd}"
  }
}

// Security group for single node

resource "aws_security_group" "elasticsearch_single_node_security_group" {
  count = "${var.cluster_mode == "false" ? "1" : "0"}"
  name = "elasticsearch-single-node-security-groups"
  description = "single node access HTTP access outside from node"
  vpc_id = "${var.vpc_id}"

  tags {
    Name = "${var.es_cluster}-singlenode"
    cluster = "${var.es_cluster}"
  }

  # allow HTTP access to client nodes via port 8080 - better to disable, and either way always password protect!
  ingress {
    from_port         = 8080
    to_port           = 8080
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  # allow HTTP access to client nodes via port 3000 for Grafana which has it's own login screen
  ingress {
    from_port         = 3000
    to_port           = 3000
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  # allow HTTP access to elb  via port 9200 for elastic serach access
  ingress {
    from_port         = 9200
    to_port           = 9200
    protocol          = "tcp"
    cidr_blocks       = ["0.0.0.0/0"]
  }

  egress {
    from_port         = 0
    to_port           = 0
    protocol          = "-1"
    cidr_blocks       = ["0.0.0.0/0"]
  }
}


resource "aws_launch_configuration" "single_node" {
  // Only create if it's a single-node configuration
  count = "${var.cluster_mode == "false" ? "1" : "0"}"
  name_prefix = "elasticsearch-${var.es_cluster}-single-node"
  image_id = "${data.aws_ami.kibana_client.id}"
  instance_type = "${var.singlenode_instance_type}"
  security_groups = ["${aws_security_group.elasticsearch_single_node_security_group.id}"]
  associate_public_ip_address = false
  iam_instance_profile = "${aws_iam_instance_profile.elasticsearch.id}"
  user_data = "${data.template_file.single_node_userdata_script.rendered}"
  key_name = "${var.key_name}"

  lifecycle {
    create_before_destroy = true
  }

  ebs_block_device {
    device_name = "${var.volume_name}"
    volume_size = "${var.elasticsearch_volume_size}"
    encrypted = "${var.volume_encryption}"
  }
}

resource "aws_autoscaling_group" "single_node" {
  // Only create if it's a single-node configuration
  count = "${var.cluster_mode == "false" ? "1" : "0"}"
  name = "elasticsearch-${var.es_cluster}-single-node"
  min_size = "0"
  max_size = "1"
  desired_capacity = "${var.cluster_mode == "false" ? "1" : "0"}"
  default_cooldown = 30
  force_delete = true
  launch_configuration = "${aws_launch_configuration.single_node.id}"

  vpc_zone_identifier = ["${data.aws_subnet_ids.selected.ids}"]
  
  tag {
    key = "Name"
    value = "${format("%s-elasticsearch", var.es_cluster)}"
    propagate_at_launch = true
  }
  tag {
    key = "Environment"
    value = "${var.environment}"
    propagate_at_launch = true
  }
  tag {
    key = "Cluster"
    value = "${var.environment}-${var.es_cluster}"
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
