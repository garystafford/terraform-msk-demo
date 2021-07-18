resource "aws_msk_configuration" "mks_config_iam" {
  kafka_versions = [
    "2.8.0"
  ]
  name = "demo-mks-config-iam"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
PROPERTIES
}

resource "aws_msk_cluster" "msk_cluster_iam" {
  cluster_name           = var.cluster_name_iam
  kafka_version          = "2.8.0"
  number_of_broker_nodes = 2
  configuration_info {
    arn      = aws_msk_configuration.mks_config_iam.arn
    revision = 1
  }

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = 120
    client_subnets = [
      aws_subnet.subnet_az1.id,
      aws_subnet.subnet_az2.id
    ]
    security_groups = [
      aws_security_group.sg.id
    ]
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
  }

  client_authentication {
    sasl {
      iam = true
    }
  }

  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }

  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.test.name
      }
    }
  }

  tags = {
    Name = "Amazon MSK Demo Cluster IAM"
  }
}

resource "aws_ssm_parameter" "param_mks_iam_zoo" {
  name  = "/msk/iam/zookeeper"
  type  = "StringList"
  value = aws_msk_cluster.msk_cluster_iam.zookeeper_connect_string
}

resource "aws_ssm_parameter" "param_mks_iam_brokers" {
  name  = "/msk/iam/brokers"
  type  = "StringList"
  value = aws_msk_cluster.msk_cluster_iam.bootstrap_brokers_sasl_iam
}
