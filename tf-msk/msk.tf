resource "aws_msk_configuration" "mks_config" {
  kafka_versions = [
    "2.6.1"
  ]
  name = "demo-mks-config"

  server_properties = <<PROPERTIES
auto.create.topics.enable = true
delete.topic.enable = true
PROPERTIES
}

resource "aws_msk_cluster" "msk_cluster" {
  cluster_name           = var.cluster_name
  kafka_version          = "2.8.0"
  number_of_broker_nodes = 3
  configuration_info {
    arn      = aws_msk_configuration.mks_config.arn
    revision = 1
  }

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    ebs_volume_size = 120
    client_subnets = [
      aws_subnet.subnet_az1.id,
      aws_subnet.subnet_az2.id,
      aws_subnet.subnet_az3.id,
    ]
    security_groups = [
    aws_security_group.sg.id]
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
        enabled   = true
        log_group = aws_cloudwatch_log_group.test.name
      }
      firehose {
        enabled         = true
        delivery_stream = aws_kinesis_firehose_delivery_stream.test_stream.name
      }
      s3 {
        enabled = true
        bucket  = aws_s3_bucket.bucket.id
        prefix  = "logs/msk-"
      }
    }
  }

  tags = {
    Name = "Amazon MSK Demo Cluster"
  }
}

resource "aws_ssm_parameter" "param_mks_access_none_zoo" {
  name  = "/msk/access-none/zookeeper"
  type  = "StringList"
  value = aws_msk_cluster.msk_cluster.zookeeper_connect_string
}

resource "aws_ssm_parameter" "param_mks_access_none_brokers" {
  name  = "/msk/access-none/brokers"
  type  = "StringList"
  value = aws_msk_cluster.msk_cluster.bootstrap_brokers_tls
}