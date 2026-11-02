#!/bin/bash
set -euxo pipefail

# Update package lists and install required packages
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ansible git

# Clone project repository
if [ ! -d /home/ubuntu/CIS-BenchMark-MongoDB/.git ]; then
  runuser -u ubuntu -- git clone \\
    https://github.com/PhuSon26/CIS-BenchMark-MongoDB.git \\
    /home/ubuntu/CIS-BenchMark-MongoDB
fi

# Create inventory on the Ansible Controller
ANSIBLE_DIR="/home/ubuntu/CIS-BenchMark-MongoDB/ansible"
mkdir -p "$ANSIBLE_DIR"

cat > "$ANSIBLE_DIR/inventory.ini" <<'INVENTORY'
[controller]
controller ansible_connection=local ansible_become=false

[mongodb]
${mongodb_hosts}

[mongodb:vars]
ansible_user=ubuntu
ansible_become=true
ansible_ssh_common_args=-o StrictHostKeyChecking=accept-new
INVENTORY

chown ubuntu:ubuntu "$ANSIBLE_DIR/inventory.ini"
