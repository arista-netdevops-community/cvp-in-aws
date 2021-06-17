variable "aws_subnet" {
  type = string
}

variable "cluster_name" {
  type = string
}
variable "cluster_size" {
  type =  string
}
variable "cluster_zone" {
  type    = string
  default = null
}
variable "cluster_public_management" {
  type    = bool
  default = false
}

variable "vm_admin_user" {
  type    = string
  default = "cvpadmin"
}
variable "vm_disk_device" {
  type    = string
  default = "sdx"
}
variable "vm_disk_type" {
  type    = string
  default = "gp3"
}
variable "vm_disk_size" {
  type    = number
  default = 1024
}
variable "vm_image" {
  type = string
}
variable "vm_remove_data_disk" {
  type    = bool
  default = false
}
variable "vm_ssh_key" {
  type    = string
  default = null
}
variable "vm_type" {
  type = string
}

variable "cluster_public_eos_communication" {
  type    = bool
  default = false
}
variable "eos_ip_range" {
  type    = list
  default = []
}