# azure-terraform
Azure cloud automation


## Development environment

This repository contains a [Dev Container](https://containers.dev/) configuration.
Open the project in GitHub Codespaces or in VS Code with the Dev Containers extension
and choose **Reopen in Container**. The dev container installs Terraform and Ansible via the included `Dockerfile` and adds Azure CLI using a Dev Container feature.
All tools are available automatically.

### Getting started

1. Open the repository in VS Code.
2. Reopen in Container when prompted.
3. Use the integrated terminal to run Terraform and Ansible commands.
## Usage
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
VM_PUBLIC_IP=$(terraform -chdir=terraform output -raw vm_public_ip)

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
  --scope /subscriptions/<subscription-id>/resourceGroups/<rg-name>
```

OBJECT_ID - your user object id from Entra ID (former AD). Entra ID -> Manage -> Users -> your user

### Secret already exists, need to import to terraform

```
terraform -chdir=terraform import azurerm_key_vault_secret.<secret-name> https://<vault>.vault.azure.net/secrets/<secret-name>/<version>
```

### Debug with sidecar

In case of different errors inside of the cluster, this sidecar can help a lot:

```
kubectl debug -n <namespace> <pod-id> -it --image=nicolaka/netshoot --share-processes --copy-to=<namespace>-debug
```
