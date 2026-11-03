
#!/bin/bash
set -euxo pipefail

# 1. Install Ansible and Git
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y ansible git

# 2. Clone repository from GitHub
REPO_DIR="/home/ubuntu/CIS-BenchMark-MongoDB"

if [ ! -d "$REPO_DIR/.git" ]; then
    runuser -u ubuntu -- git clone \
        https://github.com/PhuSon26/CIS-BenchMark-MongoDB.git \
        "$REPO_DIR"
fi

# 3. Create Ansible inventory
ANSIBLE_DIR="$REPO_DIR/ansible"
mkdir -p "$ANSIBLE_DIR"

cat > "$ANSIBLE_DIR/inventory.ini" <<'INVENTORY'
[controllers]
controller ansible_connection=local

[mongodb]
${mongodb_hosts}

[mongodb:vars]
ansible_user=ubuntu
ansible_become=true
ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'
INVENTORY

# 4. Set ownership
chown -R ubuntu:ubuntu "$REPO_DIR"

echo "====================================="
echo "Controller initialization completed"
echo "Repository: $REPO_DIR"
echo "Inventory: $ANSIBLE_DIR/inventory.ini"
echo "====================================="
