# hetzner-terraform
Azure cloud automation

## Prerequizites

The later described for Ubuntu system.

* terraform
* az cli
* Azure subscription
* ansible-playbook
* `~/.ssh/id_ed25519.pub` and `~/.ssh/id_ed25519`

All commands listed below you are expected to run on your local machine.

### Install Terraform

```
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update
sudo apt-get install terraform
terraform -help
```

In case of problems, check the latest installation procedures [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)

### Install Azure CLI

```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

In case of problems, check the latest installation procedures [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux)

### Login to Azure

Simple login

```
az loing
```

if that didn't work, you might need 

```
az login --use-device-code
```


### Apply Terraform

```
terraform apply -var-file="main.tfvars"
```

### Install ansible

```
python3 -m venv ~/ansible-venv
source ~/ansible-venv/bin/activate
pip install ansible
```

In case of problems, check the latest installation procedures [here](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu)

### Add your values to vars.yml

1. Move vars.yml.example to vars.yml

`mv ansible/vars.yml.example ansible/vars.yml`

### Install Ansible requirements

```
ansible-galaxy collection install -r ansible/requirements.yml
pip install -r ~/.ansible/collections/ansible_collections/azure/azcollection/requirements-azure.txt
```

### Run Ansible playbook

```
VM_PUBLIC_IP=$(terraform output -raw vm_public_ip)

ansible-playbook -i "${VM_PUBLIC_IP}," -u adminuser --private-key=~/.ssh/id_ed25519 ansible/playbook.yml
```

## Troubleshooting

### Error when applying TF: Caller is not allowed to change permission model

You need User Access Administrator role to manage key vault after that.

You cannot assign the User Access Administrator role from Terraform when creating the resource group because Terraform requires elevated permissions to manage role assignments, and your current execution identity doesn't have the necessary privileges to perform this action within the same Terraform run. This creates a chicken-and-egg problem:

Terraform needs elevated permissions (like User Access Administrator) to assign roles.
Without these permissions, Terraform cannot assign the required roles to itself or other identities.

```
az role assignment create \
  --assignee <OBJECT_ID> \
  --role "User Access Administrator" \
  --scope /subscriptions/<subscription-id>/resourceGroups/longlegs-resources
```

OBJECT_ID - your user object id from Entra ID (former AD). Entra ID -> Manage -> Users -> your user

### Debug with sidecar

In case of different errors inside of the cluster, this sidecar can help a lot:

```
kubectl debug -n <namespace> <pod-id> -it --image=nicolaka/netshoot --share-processes --copy-to=<namespace>-debug
```
