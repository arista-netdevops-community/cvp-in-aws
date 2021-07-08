# Example Configurations
The files provided here are for reference only and are not meant for use without tweaks.

## one-node-cvp-deployment.tfvars
Publically-accessible CVP single node deployment. This is a good way to quickly start using CVP, and will setup the environment in a way that it can be immediately used:
- Creates a new network on the selected GCP project
- Creates one CVP instance and installs the default version of CVP in it
- Enables advanced login options to allow EOS devices to self-register
- Sets up firewall rules so management and ingest ports are publically accessible
- Deploys the module's default CVP version

## multi-node-cvp-deployment.tfvars
Publically-accessible CVP multi-node deployment.
- Similar to the single node deployment above, but also uses a specific CVP version (2021.1.0) and deploys a 3-node cluster.