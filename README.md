# cvp-in-aws

Templates to launch fully functional CVP clusters in AWS.

<!-- vscode-markdown-toc -->
* 1. [TLDR](#TLDR)
* 2. [Requisites](#Requisites)
	* 2.1. [terraform](#terraform)
	* 2.2. [AWS CLI](#AWSCLI)
	* 2.3. [ansible](#ansible)
* 3. [Quickstart](#Quickstart)
* 4. [Adding EOS devices](#AddingEOSdevices)
* 5. [Variables](#Variables)
* 6. [Requirements](#Requirements)
* 7. [Providers](#Providers)
* 8. [Modules](#Modules)
* 9. [Resources](#Resources)
* 10. [Inputs](#Inputs)
* 11. [Outputs](#Outputs)
* 12. [Examples](#Examples)
	* 12.1. [Using a `.tfvars` file](#Usinga.tfvarsfile)
* 13. [Removing the environment](#Removingtheenvironment)
* 14. [Bugs and Limitations](#BugsandLimitations)

<!-- vscode-markdown-toc-config
	numbering=true
	autoSave=true
	/vscode-markdown-toc-config -->
<!-- /vscode-markdown-toc -->

##  1. <a name='TLDR'></a>TLDR
Install terraform, ansible, AWS CLI (version 2) and use one of the provided `.tfvars` examples.

##  2. <a name='Requisites'></a>Requisites
###  2.1. <a name='terraform'></a>terraform
This module is tested with terraform `1.0.1`, but should work with any terraform newer than the version shown below. You can [download it from the official website][terraform-download].

Terraform is distributed as a single binary. Install Terraform by unzipping it and moving it to a directory included in your system's `PATH`.

<!-- BEGIN_TF_REQS -->
#### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.14 |

#### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.48.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.1.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 3.1.0 |

#### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cvp_cluster"></a> [cvp\_cluster](#module\_cvp\_cluster) | ./modules/cvp-cluster | n/a |
| <a name="module_cvp_provision_nodes"></a> [cvp\_provision\_nodes](#module\_cvp\_provision\_nodes) | git::https://gitlab.aristanetworks.com/tac-team/cvp-ansible-provisioning.git | v3.0.0 |
<!-- END_TF_REQS -->

###  2.2. <a name='AWSCLI'></a>AWS CLI
You must have the AWS CLI version 2 installed and authenticated. For installation details please see [here][aws-install].

We suggest that you create a profile and authenticate the cli using these steps. Feel free to change `cvp-profile` to whatever profile name you prefer:

1. Initialize your aws profile
```bash
$ aws configure --profile cvp-profile
AWS Access Key ID [None]: YOUR_ACCESS_KEY
AWS Secret Access Key [None]: YOUR_SECRET_ACCESS_KEY
Default region name [None]: us-east-2
Default output format [None]:
```

###  2.3. <a name='ansible'></a>ansible
You must have ansible installed for provisioning to work. You can check installation instructions [here][ansible-install].

##  3. <a name='Quickstart'></a>Quickstart
These steps assume that you created a profile following the steps in the [AWS CLI](#AWSCLI) section. You must also be in the project's directory (`cvp-in-aws`):

- Initialize Terraform (only needed on the first run):

```bash
$ terraform init
```

- Edit the `examples/one-node-cvp-deployment.tfvars` file and replace with the desired values.
```
$ vi examples/one-node-cvp-deployment.tfvars
```

- Plan your full provisioning run:

```bash
$ terraform plan -out=plan.out -var-file=examples/one-node-cvp-deployment.tfvars
```

- Review your plan
- Apply the generated plan: 

```bash
terraform apply plan.out
```

- Go have a coffee. At this point, CVP should be starting in your instance and may take some time to finish bringing all services up. You can ssh into your cvp instances with the displayed `cvp_cluster_ssh_user` and `cvp_cluster_nodes_ips` to check progress.

##  4. <a name='AddingEOSdevices'></a>Adding EOS devices
If devices are in a network that can't be reached by CVP they need to be added by configuring TerminAttr on the devices themselves (similar to any setup behind NAT). At the end of the
terraform run a suggested TerminAttr configuration line will be displayed containing the appropriate `ingestgrpcurl` and `ingestauth` parameters:

```
Provisioning complete. To add devices use the following TerminAttr configuration:
exec /usr/bin/TerminAttr -ingestgrpcurl=34.71.81.254:9910 -cvcompression=gzip -ingestauth=key,JkqAGsEyGPmUZ3X0 -smashexcludes=ale,flexCounter,hardware,kni,pulse,strata -ingestexclude=/Sysdb/cell/1/agent,/Sysdb/cell/2/agent -ingestvrf=default -taillogs
```

The `exec` configuration can be copy-pasted and should be usable in most scenarios.

##  5. <a name='Variables'></a>Variables
Required variables are asked at runtime unless specified on the command line. Using a [.tfvars file](terraform-tfvars) is recommended in most cases.
<!-- BEGIN_TF_DOCS -->
### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_network"></a> [aws\_network](#input\_aws\_network) | The ID of the network in which clusters will be launched. Leaving this blank will create a new network. | `string` | `null` | no |
| <a name="input_aws_network_cidr"></a> [aws\_network\_cidr](#input\_aws\_network\_cidr) | CIDR for the AWS VPC that's created by the module. Only used when aws\_network is NOT set. | `string` | `"10.128.0.0/20"` | no |
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS CLI profile. Must match a valid profile in your ~/.aws/config and ~/.aws/credentials. | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The region in which all AWS resources will be launched. | `string` | n/a | yes |
| <a name="input_aws_start_instances"></a> [aws\_start\_instances](#input\_aws\_start\_instances) | Whether to start CVP instances when running terraform. | `bool` | `false` | no |
| <a name="input_aws_subnet"></a> [aws\_subnet](#input\_aws\_subnet) | The ID of the subnet in which clusters will be launched. Only used when aws\_network is set. | `string` | `null` | no |
| <a name="input_aws_subnet_cidr"></a> [aws\_subnet\_cidr](#input\_aws\_subnet\_cidr) | The subnetwork CIDR in which clusters will be launched. Only used when aws\_network is NOT set. | `string` | `"10.128.0.0/20"` | no |
| <a name="input_aws_zone"></a> [aws\_zone](#input\_aws\_zone) | The zone in which all GCP resources will be launched. | `string` | n/a | yes |
| <a name="input_cvp_cluster_centos_version"></a> [cvp\_cluster\_centos\_version](#input\_cvp\_cluster\_centos\_version) | The Centos version used by CVP instances. | `string` | `null` | no |
| <a name="input_cvp_cluster_name"></a> [cvp\_cluster\_name](#input\_cvp\_cluster\_name) | The name of the CVP cluster | `string` | n/a | yes |
| <a name="input_cvp_cluster_public_eos_communitation"></a> [cvp\_cluster\_public\_eos\_communitation](#input\_cvp\_cluster\_public\_eos\_communitation) | Whether the ports used by EOS devices to communicate to CVP are publically accessible over the internet. | `bool` | `false` | no |
| <a name="input_cvp_cluster_public_management"></a> [cvp\_cluster\_public\_management](#input\_cvp\_cluster\_public\_management) | Whether the cluster management interface (https/ssh) is publically accessible over the internet. | `bool` | `false` | no |
| <a name="input_cvp_cluster_remove_disks"></a> [cvp\_cluster\_remove\_disks](#input\_cvp\_cluster\_remove\_disks) | Whether data disks created for the instances will be removed when destroying them. | `bool` | `false` | no |
| <a name="input_cvp_cluster_size"></a> [cvp\_cluster\_size](#input\_cvp\_cluster\_size) | The number of nodes in the CVP cluster | `number` | n/a | yes |
| <a name="input_cvp_cluster_vm_admin_user"></a> [cvp\_cluster\_vm\_admin\_user](#input\_cvp\_cluster\_vm\_admin\_user) | User that will be used to connect to CVP cluster instances. | `string` | `"cvpsshadmin"` | no |
| <a name="input_cvp_cluster_vm_key"></a> [cvp\_cluster\_vm\_key](#input\_cvp\_cluster\_vm\_key) | Public SSH key used to access instances in the CVP cluster. | `string` | `null` | no |
| <a name="input_cvp_cluster_vm_password"></a> [cvp\_cluster\_vm\_password](#input\_cvp\_cluster\_vm\_password) | Password used to access instances in the CVP cluster. | `string` | `null` | no |
| <a name="input_cvp_cluster_vm_private_key"></a> [cvp\_cluster\_vm\_private\_key](#input\_cvp\_cluster\_vm\_private\_key) | Private SSH key used to access instances in the CVP cluster. | `string` | `null` | no |
| <a name="input_cvp_cluster_vm_type"></a> [cvp\_cluster\_vm\_type](#input\_cvp\_cluster\_vm\_type) | The type of instances used for CVP | `string` | `"c5.4xlarge"` | no |
| <a name="input_cvp_download_token"></a> [cvp\_download\_token](#input\_cvp\_download\_token) | Arista Portal token used to download CVP. | `string` | n/a | yes |
| <a name="input_cvp_enable_advanced_login_options"></a> [cvp\_enable\_advanced\_login\_options](#input\_cvp\_enable\_advanced\_login\_options) | Whether to enable advanced login options on CVP. | `bool` | `false` | no |
| <a name="input_cvp_ingest_key"></a> [cvp\_ingest\_key](#input\_cvp\_ingest\_key) | Key that will be used to authenticate devices to CVP. | `string` | `null` | no |
| <a name="input_cvp_install_size"></a> [cvp\_install\_size](#input\_cvp\_install\_size) | CVP installation size. | `string` | `null` | no |
| <a name="input_cvp_k8s_cluster_network"></a> [cvp\_k8s\_cluster\_network](#input\_cvp\_k8s\_cluster\_network) | Internal network that will be used inside the k8s cluster. Applies only to 2021.1.0+. | `string` | `"10.42.0.0/16"` | no |
| <a name="input_cvp_ntp"></a> [cvp\_ntp](#input\_cvp\_ntp) | NTP server used to keep time synchronization between CVP nodes. | `string` | `"time.google.com"` | no |
| <a name="input_cvp_version"></a> [cvp\_version](#input\_cvp\_version) | CVP version to install on the cluster. | `string` | `"2020.3.1"` | no |
| <a name="input_cvp_vm_image"></a> [cvp\_vm\_image](#input\_cvp\_vm\_image) | Image used to launch VMs. | `string` | `null` | no |
| <a name="input_eos_ip_range"></a> [eos\_ip\_range](#input\_eos\_ip\_range) | IP ranges used by EOS devices that will be managed by the CVP cluster. | `list(any)` | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_cvp_instances_credentials"></a> [cvp\_instances\_credentials](#output\_cvp\_instances\_credentials) | Public IP addresses and usernames of the cluster instances. |
| <a name="output_cvp_terminattr_instructions"></a> [cvp\_terminattr\_instructions](#output\_cvp\_terminattr\_instructions) | Instructions to add EOS devices to the CVP cluster. |
<!-- END_TF_DOCS -->

##  12. <a name='Examples'></a>Examples
###  12.1. <a name='Usinga.tfvarsfile'></a>Using a `.tfvars` file
**Note**: Before running this please replace `cvp_download_token` with your Arista Portal token and change/remove `aws_profile` to match your configuration.

```bash
$ terraform apply -var-file=examples/one-node-cvp-deployment.tfvars
```

##  13. <a name='Removingtheenvironment'></a>Removing the environment
In order to remove the environment you launched you can run the following command:

```bash
$ terraform destroy -var-file=examples/one-node-cvp-deployment.tfvars
```

This command removes everything from the AWS project.

##  14. <a name='BugsandLimitations'></a>Bugs and Limitations
- Resizing clusters is not supported at this time.
- This module connects to the instance using the `root` user instead of the declared user for provisioning due to limitations in the base image that's being used. If you know your way around terraform and understand what you're doing, this behavior can be changed by editing the `modules/cvp-provision/main.tf` file.
- CVP installation size auto-discovery only works for custom instances at this time.


[ansible-install]: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html#installing-the-ansible-community-package
[aws-install]: https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-linux.html
[gcloud-install]: https://cloud.google.com/sdk/docs/install
[terraform-download]: https://www.terraform.io/downloads.html
[terraform-tfvars]: https://www.terraform.io/docs/language/values/variables.html#variable-definitions-tfvars-files