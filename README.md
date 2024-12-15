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
az login --tenant <your tenant> --use-device-code
```


### Apply Terraform

```
terraform apply -var-file="main.tfvars"
```

### Install ansible

```
sudo apt update
sudo apt install software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible
```

In case of problems, check the latest installation procedures [here](https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-ubuntu)

### Add your values to vars.yml

1. Move vars.yml.example to vars.yml

`mv ansible/vars.yml.example ansible/vars.yml`

### Run Ansible playbook

```
VM_PUBLIC_IP=$(terraform output -raw vm_public_ip)

ansible-playbook -i "${VM_PUBLIC_IP}," -u adminuser --private-key=~/.ssh/id_ed25519 ansible/playbook.yml
```

### Debug with sidecar

```
kubectl debug -n <namespace> <pod-id> -it --image=nicolaka/netshoot --share-processes --copy-to=<namespace>-debug
```
