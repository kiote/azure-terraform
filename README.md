# hetzner-terraform
Hetzner cloud automation

## Prerequizites

The later described for Ubuntu system.

* terraform
* az cli

### Install Terraform

Check the latest installation procedures [here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)


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

### Change vars

Copy tfvars.example file:

`cp main.tfvars.example main.tfvars`

### Install Azure CLI

Check the latest installation procedures [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-linux)

```
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

### Login to Azure

Simple login

```
az loing
```

if that didn't work, you might need 

```
az login --tenant <your tenant> --use-device-code
```


### Apply

```
terraform apply -var-file="main.tfvars"
```