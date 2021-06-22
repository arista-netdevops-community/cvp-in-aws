locals {
  eos_range      = var.cluster_public_eos_communication == true ? ["0.0.0.0/0"] : var.eos_ip_range
  aws_subnet_ids = distinct(data.aws_subnet.cvp_nodes[*].id)
}

resource "aws_key_pair" "cvp_nodes" {
  key_name   = "key-${var.cluster_name}"
  public_key = var.vm_ssh_key
}

resource "aws_ebs_volume" "cvp_nodes" {
  count             = var.cluster_size
  availability_zone = data.aws_subnet.cvp_nodes[0].availability_zone
  size              = var.vm_disk_size
  type              = var.vm_disk_type

  tags = {
    Name        = "volume-${var.cluster_name}-${count.index}"
    Mount_Point = "/data"
  }

  # BUG: We should ideally use var.vm_remove_data_disk here, but unfortunatelly terraform
  #      does not support variables in the lifecycle block. Leaving this set to "true" to
  #      prevent unintentional data loss for now.
  # lifecycle {
  #   prevent_destroy = true
  # }
}

resource "aws_instance" "cvp_nodes" {
  count         = var.cluster_size
  ami           = var.vm_image
  instance_type = var.vm_type
  subnet_id     = data.aws_subnet.cvp_nodes[0].id
  key_name      = aws_key_pair.cvp_nodes.key_name
  vpc_security_group_ids = [
    aws_security_group.cvp_egress[0].id,
    aws_security_group.cvp_management[0].id,
    aws_security_group.cvp_eos-cvp[0].id,
    aws_security_group.cvp_cvp-cvp[0].id
  ]

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

resource "aws_security_group" "cvp_egress" {
  count       = 1
  name        = "fw-cvp-${var.cluster_name}-egress"
  description = "Allow CVP servers to connect to the internet."
  vpc_id      = data.aws_subnet.cvp_nodes[0].vpc_id

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "cvp_management" {
  count       = var.cluster_public_management == true ? 1 : 0
  name        = "fw-cvp-${var.cluster_name}-mgmt"
  description = "Allow users to access CVP management interfaces."
  vpc_id      = data.aws_subnet.cvp_nodes[0].vpc_id

  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow SSH connections"
    from_port        = 22
    protocol         = "tcp"
    to_port          = 22
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    cidr_blocks      = ["0.0.0.0/0"]
    description      = "Allow HTTPS connections"
    from_port        = 443
    protocol         = "tcp"
    to_port          = 443
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "cvp_eos-cvp" {
  count       = 1
  name        = "fw-cvp-${var.cluster_name}-eos-cvp"
  description = "Allow EOS-CVP communication."
  vpc_id      = data.aws_subnet.cvp_nodes[0].vpc_id

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
  count       = 1
  name        = "fw-cvp-${var.cluster_name}-cvp-cvp"
  description = "Allow CVP-CVP cluster communication. Obtained from /cvpi/tools/firewallConf.py --dumpPorts."
  vpc_id      = data.aws_subnet.cvp_nodes[0].vpc_id

  ingress {
    self      = true
    from_port = 6090
    to_port   = 6092
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 7077
    to_port   = 7077
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9200
    to_port   = 9200
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 7070
    to_port   = 7070
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9092
    to_port   = 9092
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 2890
    to_port   = 2890
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 17040
    to_port   = 17040
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 17000
    to_port   = 17000
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 10250
    to_port   = 10250
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9300
    to_port   = 9300
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9942
    to_port   = 9942
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 6783
    to_port   = 6783
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 7078
    to_port   = 7078
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 7079
    to_port   = 7079
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9943
    to_port   = 9943
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 7074
    to_port   = 7074
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 15020
    to_port   = 15020
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 2888
    to_port   = 2888
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 2889
    to_port   = 2889
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 2222
    to_port   = 2222
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 7072
    to_port   = 7072
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 7073
    to_port   = 7073
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 2380
    to_port   = 2380
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 16000
    to_port   = 16000
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9100
    to_port   = 9100
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 6061
    to_port   = 6061
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 6062
    to_port   = 6062
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 6063
    to_port   = 6063
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 3890
    to_port   = 3890
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 8901
    to_port   = 8901
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 2379
    to_port   = 2379
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 16201
    to_port   = 16201
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 19531
    to_port   = 19531
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 580
    to_port   = 580
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 15090
    to_port   = 15090
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 15010
    to_port   = 15010
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 2181
    to_port   = 2181
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 6443
    to_port   = 6443
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9001
    to_port   = 9001
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 8020
    to_port   = 8020
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9093
    to_port   = 9093
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 15075
    to_port   = 15075
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9900
    to_port   = 9900
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 15070
    to_port   = 15070
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 5443
    to_port   = 5443
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 12012
    to_port   = 12013
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 3889
    to_port   = 3889
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 3888
    to_port   = 3888
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 8480
    to_port   = 8480
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 8481
    to_port   = 8481
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9940
    to_port   = 9940
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9941
    to_port   = 9941
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 8485
    to_port   = 8485
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 9944
    to_port   = 9944
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 7075
    to_port   = 7075
    protocol  = "tcp"
  }
  ingress {
    self      = true
    from_port = 7076
    to_port   = 7076
    protocol  = "tcp"
  }

  ingress {
    self      = true
    from_port = 694
    to_port   = 694
    protocol  = "udp"
  }
  ingress {
    self      = true
    from_port = 8472
    to_port   = 8472
    protocol  = "udp"
  }

  egress {
    self      = true
    protocol  = -1
    from_port = 0
    to_port   = 0
  }
}