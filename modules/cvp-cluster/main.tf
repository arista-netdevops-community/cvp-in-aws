locals {
  eos_range = var.cluster_public_eos_communication == true ? ["0.0.0.0/0"] : var.eos_ip_range
}

resource "aws_key_pair" "cvp_nodes" {
  key_name   = "key-${var.cluster_name}"
  public_key = var.vm_ssh_key
}

resource "aws_ebs_volume" "cvp_nodes" {
  count             = var.cluster_size
  availability_zone = data.aws_subnet.cvp_nodes.availability_zone
  size              = var.vm_disk_size
  type              = var.vm_disk_type

  tags = {
    Name = "volume-${var.cluster_name}-${count.index}"
    Mount_Point = "/data"
  }

  # BUG: We should ideally use var.vm_remove_data_disk here, but unfortunatelly terraform
  #      does not support variables in the lifecycle block. Leaving this set to "true" to
  #      prevent unintentional data loss for now.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_instance" "cvp_nodes" {
  count                  = var.cluster_size
  ami                    = var.vm_image
  instance_type          = var.vm_type
  subnet_id              = data.aws_subnet.cvp_nodes.id
  key_name               = aws_key_pair.cvp_nodes.key_name
  vpc_security_group_ids = [ aws_security_group.cvp_management[0].id, aws_security_group.cvp_eos-cvp.id, aws_security_group.cvp_cvp-cvp.id ]

  tags = {
    Name = "vm-${var.cluster_name}-${count.index}"
  }

  lifecycle {
    ignore_changes = [
      ebs_block_device
    ]
  }
}

resource "aws_eip" "cvp_nodes" {
  count    = var.cluster_size
  instance = aws_instance.cvp_nodes[count.index].id
  vpc      = true
}

resource "aws_volume_attachment" "cvp_nodes" {
  count       = var.cluster_size
  volume_id   = aws_ebs_volume.cvp_nodes[count.index].id
  instance_id = aws_instance.cvp_nodes[count.index].id
  device_name = var.vm_disk_device
}

resource "aws_security_group" "cvp_management" {
  count       = var.cluster_public_management == true ? 1 : 0
  name        = "fw-cvp-${var.cluster_name}-mgmt"
  description = "Allow users to access CVP management interfaces."
  vpc_id      = data.aws_subnet.cvp_nodes.vpc_id

  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow SSH connections"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    ipv6_cidr_blocks = [ "::/0" ]
  }
  ingress {
    cidr_blocks = [ "0.0.0.0/0" ]
    description = "Allow HTTPS connections"
    from_port   = 443
    protocol    = "tcp"
    to_port     = 443
    ipv6_cidr_blocks = [ "::/0" ]
  }
}

resource "aws_security_group" "cvp_eos-cvp" {
  name        = "fw-cvp-${var.cluster_name}-eos-cvp"
  description = "Allow EOS-CVP communication."
  vpc_id      = data.aws_subnet.cvp_nodes.vpc_id

  ingress {
    cidr_blocks = local.eos_range
    description = "Allow ingest-port connections"
    from_port   = 9910
    protocol    = "tcp"
    to_port     = 9910
  }
  ingress {
    cidr_blocks = local.eos_range
    description = "Allow ambassador connections"
    from_port   = 8443
    protocol    = "tcp"
    to_port     = 8443
  }
  ingress {
    cidr_blocks = local.eos_range
    description = "Allow wifimanager connections"
    from_port   = 4433
    protocol    = "tcp"
    to_port     = 4433
  }
  ingress {
    cidr_blocks = local.eos_range
    description = "Allow wifimanager connections"
    from_port   = 8090
    protocol    = "tcp"
    to_port     = 8090
  }
  ingress {
    cidr_blocks = local.eos_range
    description = "Allow snmp connections"
    from_port   = 161
    protocol    = "udp"
    to_port     = 161
  }
  ingress {
    cidr_blocks = local.eos_range
    description = "Allow wifimanager connections"
    from_port   = 3851
    protocol    = "udp"
    to_port     = 3851
  }
}

resource "aws_security_group" "cvp_cvp-cvp" {
  name        = "fw-cvp-${var.cluster_name}-cvp-cvp"
  description = "Allow CVP-CVP cluster communication. Obtained from /cvpi/tools/firewallConf.py --dumpPorts."
  vpc_id      = data.aws_subnet.cvp_nodes.vpc_id

  ingress {
    self        = true
    from_port   = 6090
    to_port     = 6092
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 7077
    to_port     = 7077
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9200
    to_port     = 9200
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 7070
    to_port     = 7070
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 2890
    to_port     = 2890
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 17040
    to_port     = 17040
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 17000
    to_port     = 17000
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9300
    to_port     = 9300
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9942
    to_port     = 9942
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 6783
    to_port     = 6783
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 7078
    to_port     = 7078
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 7079
    to_port     = 7079
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9943
    to_port     = 9943
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 7074
    to_port     = 7074
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 15020
    to_port     = 15020
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 2888
    to_port     = 2888
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 2889
    to_port     = 2889
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 2222
    to_port     = 2222
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 7072
    to_port     = 7072
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 7073
    to_port     = 7073
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 2380
    to_port     = 2380
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 16000
    to_port     = 16000
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 6061
    to_port     = 6061
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 6062
    to_port     = 6062
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 6063
    to_port     = 6063
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 3890
    to_port     = 3890
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 8901
    to_port     = 8901
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 2379
    to_port     = 2379
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 16201
    to_port     = 16201
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 19531
    to_port     = 19531
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 580
    to_port     = 580
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 15090
    to_port     = 15090
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 15010
    to_port     = 15010
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9001
    to_port     = 9001
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 8020
    to_port     = 8020
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 15075
    to_port     = 15075
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9900
    to_port     = 9900
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 15070
    to_port     = 15070
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 5443
    to_port     = 5443
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 12012
    to_port     = 12013
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 3889
    to_port     = 3889
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 3888
    to_port     = 3888
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 8480
    to_port     = 8480
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 8481
    to_port     = 8481
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9940
    to_port     = 9940
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9941
    to_port     = 9941
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 8485
    to_port     = 8485
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 9944
    to_port     = 9944
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 7075
    to_port     = 7075
    protocol    = "tcp"
  }
  ingress {
    self        = true
    from_port   = 7076
    to_port     = 7076
    protocol    = "tcp"
  }
  
  ingress {
    self        = true
    from_port   = 694
    to_port     = 694
    protocol    = "udp"
  }
  ingress {
    self        = true
    from_port   = 8472
    to_port     = 8472
    protocol    = "udp"
  }

  egress {
    self      = true
    protocol  = -1
    from_port = 0
    to_port   = 0
  }
}


# resource "google_compute_instance_group_manager" "cvp_nodes" {
#   name               = "igm-cvp-nodes-${var.cluster_name}"
#   project            = data.google_project.project.project_id
#   base_instance_name = var.cluster_name
#   zone               = var.cluster_zone

#   version {
#     instance_template  = google_compute_instance_template.cvp_nodes.id
#   }

#   target_size  = var.cluster_size

#   named_port {
#     name = "ssh"
#     port = 22
#   }
#   named_port {
#     name = "http"
#     port = 80
#   }
#   named_port {
#     name = "https"
#     port = 443
#   }
#   named_port {
#     name = "namenode"
#     port = 8020
#   }
#   named_port {
#     name = "namenode"
#     port = 9001
#   }
#   named_port {
#     name = "namenode"
#     port = 15070
#   }
#   named_port {
#     name = "datanode"
#     port = 15010
#   }
#   named_port {
#     name = "datanode"
#     port = 15020
#   }
#   named_port {
#     name = "datanode"
#     port = 15075
#   }
#   named_port {
#     name = "journalnode"
#     port = 8480
#   }
#   named_port {
#     name = "journalnode"
#     port = 8481
#   }
#   named_port {
#     name = "journalnode"
#     port = 8485
#   }
#   named_port {
#     name = "namenode-standby"
#     port = 15090
#   }
#   named_port {
#     name = "zookeeper"
#     port = 2181
#   }
#   named_port {
#     name = "zookeeper"
#     port = 2888
#   }
#   named_port {
#     name = "zookeeper"
#     port = 3888
#   }
#   named_port {
#     name = "zookeeper"
#     port = 3889
#   }
#   named_port {
#     name = "zookeeper"
#     port = 3890
#   }
#   named_port {
#     name = "zookeeper"
#     port = 7070
#   }
#   named_port {
#     name = "zookeeper-udp"
#     port = 3888
#   }
#   named_port {
#     name = "hbase-master"
#     port = 16000
#   }
#   named_port {
#     name = "hbase-master"
#     port = 16010
#   }
#   named_port {
#     name = "hbase-master"
#     port = 7072
#   }
#   named_port {
#     name = "hbase"
#     port = 7073
#   }
#   named_port {
#     name = "hadoop"
#     port = 7074
#   }
#   named_port {
#     name = "hadoop"
#     port = 7075
#   }
#   named_port {
#     name = "hadoop"
#     port = 7076
#   }
#   named_port {
#     name = "hadoop"
#     port = 7077
#   }
#   named_port {
#     name = "regionserver"
#     port = 16201
#   }
#   named_port {
#     name = "regionserver"
#     port = 16301
#   }
#   named_port {
#     name = "kafka"
#     port = 9092
#   }
#   named_port {
#     name = "kafka"
#     port = 7078
#   }
#   named_port {
#     name = "hazelcast"
#     port = 5701
#   }
#   named_port {
#     name = "ingest"
#     port = 9910
#   }
#   named_port {
#     name = "api-server"
#     port = 9900
#   }
#   named_port {
#     name = "api-server"
#     port = 6063
#   }
#   named_port {
#     name = "dispatcher"
#     port = 9930
#   }
#   named_port {
#     name = "dispatcher"
#     port = 6064
#   }
#   named_port {
#     name = "dispatcher2"
#     port = 9931
#   }
#   named_port {
#     name = "dispatcher2"
#     port = 6065
#   }
#   named_port {
#     name = "dispatcher3"
#     port = 9932
#   }
#   named_port {
#     name = "dispatcher3"
#     port = 6066
#   }
#   named_port {
#     name = "dispatcher4"
#     port = 9933
#   }
#   named_port {
#     name = "dispatcher4"
#     port = 6067
#   }
#   named_port {
#     name = "certs"
#     port = 10093
#   }
#   named_port {
#     name = "etc"
#     port = 2379
#   }
#   named_port {
#     name = "etc"
#     port = 2380
#   }
#   named_port {
#     name = "kubelet"
#     port = 10250
#   }
#   named_port {
#     name = "kube-apiserver"
#     port = 6443
#   }
#   named_port {
#     name = "elasticsearch"
#     port = 9200
#   }
#   named_port {
#     name = "elasticsearch"
#     port = 9300
#   }
#   named_port {
#     name = "clickhouse"
#     port = 17040
#   }
#   named_port {
#     name = "clickhouse"
#     port = 17000
#   }
#   named_port {
#     name = "change-control-api"
#     port = 12010
#   }
#   named_port {
#     name = "change-control-api"
#     port = 12011
#   }
#   named_port {
#     name = "clover"
#     port = 12012
#   }
#   named_port {
#     name = "clover"
#     port = 12013
#   }
#   named_port {
#     name = "prometheus"
#     port = 9100
#   }

#   # auto_healing_policies {
#   #   health_check      = google_compute_health_check.autohealing.id
#   #   initial_delay_sec = 300
#   # }
# }

# resource "google_compute_firewall" "cvp_management" {
#   count       = var.cluster_public_management == true ? 1 : 0
#   name        = "fw-cvp-${var.cluster_name}-mgmt"
#   project     = data.google_project.project.project_id
#   network     = var.gcp_network
#   description = "Allow users to access CVP management interfaces."

#   allow {
#     protocol = "tcp"
#     ports    = ["22", "443"]
#   }

#   source_ranges = [ "0.0.0.0/0" ]
#   target_tags   = [ "arista-cvp-server" ]
# }

# resource "google_compute_firewall" "cvp_eos-cvp" {
#   name        = "fw-cvp-${var.cluster_name}-eos-cvp"
#   project     = data.google_project.project.project_id
#   network     = var.gcp_network
#   description = "Allow EOS->CVP communication"

#   allow {
#     protocol = "tcp"
#     ports    = [
#       "9910",
#       "8443",
#       "4433",
#       "8090"
#     ]
#   }

#   allow {
#     protocol = "udp"
#     ports    = [
#       "161",
#       "3851"
#     ]
#   }

#   source_ranges = local.eos_range
#   target_tags   = [ "arista-cvp-server" ]
# }

# resource "google_compute_firewall" "cvp_cvp-cvp" {
#   name        = "fw-cvp-${var.cluster_name}-cvp-cvp"
#   project     = data.google_project.project.project_id
#   network     = var.gcp_network
#   description = "Allow CVP-CVP cluster communication. Obtained from /cvpi/tools/firewallConf.py --dumpPorts."

#   allow {
#     protocol = "tcp"
#     ports = [
#       "6090-6092",
#       "7077",
#       "9200",
#       "7070",
#       "9092",
#       "2890",
#       "17040",
#       "17000",
#       "10250",
#       "9300",
#       "5432",
#       "9942",
#       "6783",
#       "7078",
#       "7079",
#       "9943",
#       "7074",
#       "15020",
#       "2888",
#       "2889",
#       "2222",
#       "7072",
#       "7073",
#       "2380",
#       "16000",
#       "9100",
#       "6061",
#       "6062",
#       "6063",
#       "3890",
#       "8901",
#       "2379",
#       "16201",
#       "19531",
#       "580",
#       "15090",
#       "15010",
#       "2181",
#       "6443",
#       "9001",
#       "8020",
#       "9093",
#       "15075",
#       "9900",
#       "15070",
#       "5443",
#       "12012-12013",
#       "3889",
#       "3888",
#       "8480",
#       "8481",
#       "9940",
#       "9941",
#       "8485",
#       "9944",
#       "7075",
#       "7076"
#     ]
#   }

#   allow {
#     protocol = "udp"
#     ports    = [
#       "694",
#       "8472"
#     ]
#   }

#   source_tags   = [ "arista-cvp-server" ]
#   target_tags   = [ "arista-cvp-server" ]
# }