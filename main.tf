# TODO: Support remote states
terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = {
      cvp-in-aws_Source  = "https://github.com/arista-netdevops-community/cvp-in-aws"
      cvp-in-aws_Version = "48d9ab60"
    }
  }
}

resource "random_string" "cvp_ingest_key" {
  length  = 16
  special = false
}

locals {
  cli = {
    aws = {
      command = var.aws_profile == null ? "aws --region ${var.aws_region}" : "aws --region ${var.aws_region} --profile ${var.aws_profile}"
    }
  }
  instance = {
    family = lower(tostring(split(".", var.cvp_cluster_vm_type)[0]))
    image = {
      centos = {
        version = var.cvp_cluster_centos_version != null ? var.cvp_cluster_centos_version : (
          (var.cvp_version == "2020.1.0" || var.cvp_version == "2020.1.1" || var.cvp_version == "2020.1.2") ? "7.6" : (
            (var.cvp_version == "2020.2.0" || var.cvp_version == "2020.2.1" || var.cvp_version == "2020.2.2" || var.cvp_version == "2020.2.3" || var.cvp_version == "2020.2.4") ? "7.7" : (
              (var.cvp_version == "2020.3.0" || var.cvp_version == "2020.3.1") ? "7.7" : (
                (var.cvp_version == "2021.1.0" || var.cvp_version == "2021.1.1") ? "7.7" : "7.7"
              )
            )
          )
        )
      }
    }
    command = {
      start = "${local.cli.aws.command} ec2 start-instances --instance-ids"
      wait  = "${local.cli.aws.command} ec2 wait instance-status-ok --instance-ids"
    }
  }
  cvp_cluster = {
    vm_image = {
      location = var.cvp_vm_image != null ? var.cvp_vm_image : (
        local.instance.image.centos.version == "7.7" ? (
          (local.instance.family == "c5" && (var.aws_region == "us-east-2" || var.aws_region == "us-east-1" || var.aws_region == "us-west-2")) ? (
            var.aws_region == "us-east-2" ? "ami-00d18ca4c8ba05cd7" : (
              var.aws_region == "ap-southeast-2" ? null : (
                var.aws_region == "ap-northeast-1" ? null : (
                  var.aws_region == "us-west-1" ? null : (
                    var.aws_region == "us-east-1" ? "ami-06cdafd0cb81c5e98" : (
                      var.aws_region == "ap-south-1" ? null : (
                        var.aws_region == "eu-west-1" ? null : (
                          var.aws_region == "ca-central-1" ? null : (
                            var.aws_region == "ap-northeast-2" ? null : (
                              var.aws_region == "us-west-2" ? "ami-086823f2b5aa4af7d" : (
                                var.aws_region == "eu-west-3" ? null : (
                                  var.aws_region == "eu-west-2" ? null : null
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
            ) : (
            var.aws_region == "us-east-2" ? "ami-08cb1262ee37c0c1a" : (
              var.aws_region == "ap-southeast-2" ? "ami-08dc4f675378ddf5d" : (
                var.aws_region == "ap-northeast-1" ? "ami-066f207333a6a72ad" : (
                  var.aws_region == "us-west-1" ? "ami-0e9d68a32c07625dc" : (
                    var.aws_region == "us-east-1" ? "ami-020951c3f3de175e9" : (
                      var.aws_region == "ap-south-1" ? "ami-06f016ea397cb4322" : (
                        var.aws_region == "eu-west-1" ? "ami-0b8e68c726b39c259" : (
                          var.aws_region == "ca-central-1" ? "ami-031cc7ebe59d3ca68" : (
                            var.aws_region == "ap-northeast-2" ? "ami-0e0f5e438394f40d5" : (
                              var.aws_region == "us-west-2" ? "ami-0b7a55361580a28ca" : (
                                var.aws_region == "eu-west-3" ? "ami-0c58089af4f2d0a1d" : (
                                  var.aws_region == "eu-west-2" ? "ami-0750eb21b251cd63f" : null
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          )
          ) : (
          local.instance.image.centos.version == "7.6" ? (
            (local.instance.family == "c5" && (var.aws_region == "us-west-2")) ? (
              var.aws_region == "us-west-2" ? "ami-0d3e12bfd75d77ea5" : null
              ) : (
              var.aws_region == "us-east-2" ? "ami-0bf21af2830b860b9" : (
                var.aws_region == "ap-southeast-2" ? "ami-0bb75ba06657fd8c1" : (
                  var.aws_region == "ap-northeast-1" ? "ami-0cfded88e130d497b" : (
                    var.aws_region == "us-west-1" ? "ami-02be0d5a83d716ea6" : (
                      var.aws_region == "us-east-1" ? "ami-08191defa0d4a23af" : (
                        var.aws_region == "ap-south-1" ? "ami-0c1424d0be7ed900e" : (
                          var.aws_region == "eu-west-1" ? "ami-035fc0048c274bdee" : (
                            var.aws_region == "ca-central-1" ? "ami-0167537db28895e3a" : (
                              var.aws_region == "ap-northeast-2" ? "ami-01e7e310c94afa3a1" : (
                                var.aws_region == "us-west-2" ? "ami-00d4ae0422100c609" : (
                                  var.aws_region == "eu-west-3" ? "ami-02faad4c80a4cfefb" : (
                                    var.aws_region == "eu-west-2" ? "ami-0c91c2ff37cf82b49" : null
                                  )
                                )
                              )
                            )
                          )
                        )
                      )
                    )
                  )
                )
              )
            )
          ) : null
        )
      )
    }
    zone = lower("${var.aws_region}${var.aws_zone}")
  }
  cvp_ingest_key = var.cvp_ingest_key != null ? var.cvp_ingest_key : random_string.cvp_ingest_key.result
}

resource "aws_vpc" "vpc_network" {
  count      = var.aws_network == null ? 1 : 0
  cidr_block = var.aws_network_cidr
  tags = {
    Name = "vpc-${var.cvp_cluster_name}"
  }
}
resource "aws_subnet" "vpc_network" {
  count                   = var.aws_network == null ? 1 : 0
  vpc_id                  = aws_vpc.vpc_network[0].id
  cidr_block              = var.aws_subnet_cidr
  map_public_ip_on_launch = (var.cvp_cluster_public_management == true || var.cvp_cluster_public_eos_communitation == true) ? true : false

  tags = {
    Name = "subnet-${var.cvp_cluster_name}"
  }
}
resource "aws_internet_gateway" "vpc_network" {
  count  = var.aws_network == null ? 1 : 0
  vpc_id = aws_vpc.vpc_network[0].id

  tags = {
    Name = "gw-${var.cvp_cluster_name}"
  }
}
resource "aws_route_table" "vpc_network" {
  count  = var.aws_network == null ? 1 : 0
  vpc_id = aws_vpc.vpc_network[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_network[0].id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.vpc_network[0].id
  }

  tags = {
    Name = "rtt-${var.cvp_cluster_name}"
  }
}
resource "aws_route_table_association" "vpc_network" {
  count          = var.aws_network == null ? 1 : 0
  subnet_id      = aws_subnet.vpc_network[0].id
  route_table_id = aws_route_table.vpc_network[0].id
}

resource "random_id" "prefix" {
  byte_length = 8
}
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}
resource "local_file" "ssh_public_key" {
  filename        = "${path.module}/dynamic/${random_id.prefix.hex}-id_rsa.pub"
  content         = tls_private_key.ssh.public_key_openssh
  file_permission = "0644"
}
resource "local_file" "ssh_private_key" {
  filename        = "${path.module}/dynamic/${random_id.prefix.hex}-id_rsa.pem"
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

# TODO: Support instances in multiple zones
module "cvp_cluster" {
  source = "./modules/cvp-cluster"

  aws_subnet = var.aws_network != null ? var.aws_subnet : aws_subnet.vpc_network[0].id

  cluster_name                     = var.cvp_cluster_name
  cluster_size                     = var.cvp_cluster_size
  cluster_zone                     = local.cvp_cluster.zone
  cluster_public_management        = var.cvp_cluster_public_management
  cluster_public_eos_communication = var.cvp_cluster_public_eos_communitation
  eos_ip_range                     = var.eos_ip_range
  vm_type                          = var.cvp_cluster_vm_type
  vm_image                         = local.cvp_cluster.vm_image.location
  vm_ssh_key                       = fileexists(var.cvp_cluster_vm_key) ? "${split(" ", file(var.cvp_cluster_vm_key))[0]} ${split(" ", file(var.cvp_cluster_vm_key))[1]}" : (fileexists(abspath(local_file.ssh_public_key.filename)) ? "${split(" ", file(abspath(local_file.ssh_public_key.filename)))[0]} ${split(" ", file(abspath(local_file.ssh_public_key.filename)))[1]}" : null)
  vm_admin_user                    = var.cvp_cluster_vm_admin_user
  vm_remove_data_disk              = var.cvp_cluster_remove_disks

  depends_on = [
    aws_route_table_association.vpc_network[0]
  ]
}

resource "null_resource" "start_instances" {
  count = var.aws_start_instances == false ? 0 : length(module.cvp_cluster.nodes)
  triggers = {
    cvp_cluster_node_stopped = module.cvp_cluster.nodes[count.index].instance_state == "stopped"
  }
  provisioner "local-exec" {
    command = "${local.instance.command.start} ${module.cvp_cluster.nodes[count.index].id} && ${local.instance.command.wait} ${module.cvp_cluster.nodes[count.index].id}"
  }
}

locals {
  vm_commons = {
    ssh = {
      username = var.cvp_cluster_vm_admin_user
      private_key = var.cvp_cluster_vm_private_key != null ? (
        fileexists(var.cvp_cluster_vm_private_key) ? file(var.cvp_cluster_vm_private_key) : (
          fileexists(local_file.ssh_private_key.filename) ? file(local_file.ssh_private_key.filename) : null
        )
        ) : (
        fileexists(local_file.ssh_private_key.filename) ? file(local_file.ssh_private_key.filename) : null
      )
      private_key_path = var.cvp_cluster_vm_private_key != null ? (
        fileexists(var.cvp_cluster_vm_private_key) ? var.cvp_cluster_vm_private_key : (
          fileexists(local_file.ssh_private_key.filename) ? abspath(local_file.ssh_private_key.filename) : null
        )
        ) : (
        fileexists(local_file.ssh_private_key.filename) ? abspath(local_file.ssh_private_key.filename) : null
      )
      public_key = var.cvp_cluster_vm_key != null ? (
        fileexists(var.cvp_cluster_vm_key) ? file(var.cvp_cluster_vm_key) : (
          fileexists(abspath(local_file.ssh_public_key.filename)) ? file(abspath(local_file.ssh_public_key.filename)) : null
        )
        ) : (
        fileexists(abspath(local_file.ssh_public_key.filename)) ? file(abspath(local_file.ssh_public_key.filename)) : null
      )
      public_key_path = var.cvp_cluster_vm_key != null ? (
        fileexists(var.cvp_cluster_vm_key) ? var.cvp_cluster_vm_key : (
          fileexists(abspath(local_file.ssh_public_key.filename)) ? abspath(local_file.ssh_public_key.filename) : null
        )
        ) : (
        fileexists(abspath(local_file.ssh_public_key.filename)) ? abspath(local_file.ssh_public_key.filename) : null
      )
    }
    bootstrap = {
      username = "root"
      password = "CentosAristaCVP"
    }
  }
  vm = length(module.cvp_cluster.nodes) == 1 ? ([
    {
      ssh       = local.vm_commons.ssh
      bootstrap = local.vm_commons.bootstrap
      disk = {
        data = {
          device = (
            contains(split(".", var.cvp_cluster_vm_type), "c5") ? "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_${replace(module.cvp_cluster.data_disk[0].id, "-", "")}" : module.cvp_cluster.data_disk_attachment[0].device_name
          )
        }
      }
      cpu = {
        number = module.cvp_cluster.nodes[0].cpu_core_count * module.cvp_cluster.nodes[0].cpu_threads_per_core
      }
      memory = {
        number = module.cvp_cluster.nodes[0].cpu_core_count * 2 * 1024
      }
      network = {
        private = {
          address = module.cvp_cluster.nodes[0].private_ip
          subnet = {
            netmask       = cidrnetmask(module.cvp_cluster.subnets[0].cidr_block)
            default_route = cidrhost(module.cvp_cluster.subnets[0].cidr_block, 1)
          }
        }
        public = {
          address = module.cvp_cluster.node_ips[0].public_ip
        }
      }
      config = {
        ntp      = var.cvp_ntp
        hostname = module.cvp_cluster.node_ips[0].private_dns
      }
    }
    ]) : ([
    {
      ssh       = local.vm_commons.ssh
      bootstrap = local.vm_commons.bootstrap
      disk = {
        data = {
          device = (
            contains(split(".", var.cvp_cluster_vm_type), "c5") ? "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_${replace(module.cvp_cluster.data_disk[0].id, "-", "")}" : module.cvp_cluster.data_disk_attachment[0].device_name
          )
        }
      }
      cpu = {
        number = module.cvp_cluster.nodes[0].cpu_core_count * module.cvp_cluster.nodes[0].cpu_threads_per_core
      }
      memory = {
        number = module.cvp_cluster.nodes[0].cpu_core_count * 2 * 1024
      }
      network = {
        private = {
          address = module.cvp_cluster.nodes[0].private_ip
          subnet = {
            netmask       = cidrnetmask(module.cvp_cluster.subnets[0].cidr_block)
            default_route = cidrhost(module.cvp_cluster.subnets[0].cidr_block, 1)
          }
        }
        public = {
          address = module.cvp_cluster.node_ips[0].public_ip
        }
      }
      config = {
        ntp      = var.cvp_ntp
        hostname = module.cvp_cluster.node_ips[0].private_dns
      }
    },
    {
      ssh       = local.vm_commons.ssh
      bootstrap = local.vm_commons.bootstrap
      disk = {
        data = {
          device = (
            contains(split(".", var.cvp_cluster_vm_type), "c5") ? "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_${replace(module.cvp_cluster.data_disk[1].id, "-", "")}" : module.cvp_cluster.data_disk_attachment[1].device_name
          )
        }
      }
      cpu = {
        number = module.cvp_cluster.nodes[1].cpu_core_count * module.cvp_cluster.nodes[1].cpu_threads_per_core
      }
      memory = {
        number = module.cvp_cluster.nodes[1].cpu_core_count * 2 * 1024
      }
      network = {
        private = {
          address = module.cvp_cluster.nodes[1].private_ip
          subnet = {
            netmask       = cidrnetmask(module.cvp_cluster.subnets[1].cidr_block)
            default_route = cidrhost(module.cvp_cluster.subnets[1].cidr_block, 1)
          }
        }
        public = {
          address = module.cvp_cluster.node_ips[1].public_ip
        }
      }
      config = {
        ntp      = var.cvp_ntp
        hostname = module.cvp_cluster.node_ips[1].private_dns
      }
    },
    {
      ssh       = local.vm_commons.ssh
      bootstrap = local.vm_commons.bootstrap
      disk = {
        data = {
          device = (
            contains(split(".", var.cvp_cluster_vm_type), "c5") ? "/dev/disk/by-id/nvme-Amazon_Elastic_Block_Store_${replace(module.cvp_cluster.data_disk[2].id, "-", "")}" : module.cvp_cluster.data_disk_attachment[2].device_name
          )
        }
      }
      cpu = {
        number = module.cvp_cluster.nodes[2].cpu_core_count * module.cvp_cluster.nodes[2].cpu_threads_per_core
      }
      memory = {
        number = module.cvp_cluster.nodes[2].cpu_core_count * 2 * 1024
      }
      network = {
        private = {
          address = module.cvp_cluster.nodes[2].private_ip
          subnet = {
            netmask       = cidrnetmask(module.cvp_cluster.subnets[2].cidr_block)
            default_route = cidrhost(module.cvp_cluster.subnets[2].cidr_block, 1)
          }
        }
        public = {
          address = module.cvp_cluster.node_ips[2].public_ip
        }
      }
      config = {
        ntp      = var.cvp_ntp
        hostname = module.cvp_cluster.node_ips[2].private_dns
      }
    }
  ])
}
module "cvp_provision_nodes" {
  source = "git::https://github.com/arista-netdevops-community/cvp-ansible-provisioning.git?ref=v3.0.2"

  cloud_provider                    = "aws"
  vm                                = length(local.vm) == 1 ? [local.vm[0]] : local.vm
  cvp_version                       = var.cvp_version
  cvp_download_token                = var.cvp_download_token
  cvp_install_size                  = var.cvp_install_size != null ? var.cvp_install_size : null
  cvp_enable_advanced_login_options = var.cvp_enable_advanced_login_options
  cvp_ingest_key                    = local.cvp_ingest_key
  cvp_k8s_cluster_network           = var.cvp_k8s_cluster_network

  depends_on = [
    null_resource.start_instances
  ]
}