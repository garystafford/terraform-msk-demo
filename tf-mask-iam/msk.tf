resource "aws_kms_key" "kms" {
  description = "Amazon MSK Demo with IAM"
}

resource "aws_msk_configuration" "mks_config" {
  kafka_versions = [
    "2.8.0"]
  name = "demo-mks-config-iam"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
PROPERTIES
}

resource "aws_msk_cluster" "msk-cluster" {
  cluster_name = var.cluster_name
  kafka_version = "2.8.0"
  number_of_broker_nodes = 2
  configuration_info {
    arn = aws_msk_configuration.mks_config.arn
    revision = 1
  }

  broker_node_group_info {
    instance_type = "kafka.m5.large"
    ebs_volume_size = 1000
    client_subnets = [
      "subnet-0c923452cc7d0f173",
      "subnet-026e1a252df965ce6"
    ]
    security_groups = [
      "sg-0de51e729ae9b28cf"
    ]
  }

  client_authentication {
    sasl {
      iam = true
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = aws_kms_key.kms.arn
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
        enabled = true
        log_group = "msk_broker_logs"
      }
    }
  }

  tags = {
    Name = "Amazon MSK Demo Cluster"
  }
}
