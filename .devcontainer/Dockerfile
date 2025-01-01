# Use an official lightweight Python image as the base
FROM python:3.10-slim

# Set the working directory in the container
WORKDIR /workspace

# Install system dependencies for Ansible
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    sshpass \
    openssh-client \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Ansible using pip
RUN pip install --no-cache-dir ansible

# Optional: Install additional Ansible plugins or tools (e.g., Ansible Lint)
RUN pip install --no-cache-dir ansible-lint

# Copy any required files from the host to the container (e.g., playbooks, inventory)
# Uncomment the line below and customize the source/destination if needed
# COPY ./playbooks /workspace/playbooks

# Set environment variables for Ansible
ENV ANSIBLE_HOST_KEY_CHECKING=False
ENV PYTHONUNBUFFERED=1

# Expose a volume to allow sharing playbooks and configurations
VOLUME ["/workspace"]

# Set the default entry point to Ansible
# Uncomment and customize the CMD if you want to run a specific command by default
# CMD ["ansible-playbook", "--version"]
