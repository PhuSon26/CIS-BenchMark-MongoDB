
#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/controller-bootstrap.log) 2>&1

echo "===== Controller Bootstrap ====="

# 1. Install required packages
apt-get update

DEBIAN_FRONTEND=noninteractive apt-get install -y \
    ansible \
    git \
    openssh-server \
    python3 \
    python3-pip

# 2. Enable SSH server and Agent Forwarding
systemctl enable --now ssh

cat > /etc/ssh/sshd_config.d/60-ansible-agent-forwarding.conf <<'EOF'
AllowAgentForwarding yes
EOF

sshd -t
systemctl reload ssh

# 3. Clone GitHub repository
REPO_DIR="/home/ubuntu/CIS-BenchMark-MongoDB"

if [ ! -d "$REPO_DIR/.git" ]; then
    runuser -u ubuntu -- git clone \
        https://github.com/PhuSon26/CIS-BenchMark-MongoDB.git \
        "$REPO_DIR"
fi

ANSIBLE_DIR="$REPO_DIR/ansible"

mkdir -p "$ANSIBLE_DIR"

# 4. Generate correct Ansible inventory
cat > "$ANSIBLE_DIR/inventory.ini" <<'INVENTORY'
[controller_node]
controller ansible_connection=local

[mongodb_nodes]
${mongodb_hosts}

[all:vars]
ansible_user=ubuntu
ansible_become=true
ansible_python_interpreter=/usr/bin/python3
ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'
INVENTORY

# 5. Configure Ansible
cat > "$ANSIBLE_DIR/ansible.cfg" <<'EOF'
[defaults]
inventory = ./inventory.ini
host_key_checking = False
interpreter_python = auto_silent
timeout = 30
forks = 10

[ssh_connection]
pipelining = True
EOF

# 6. Install required Ansible collection
runuser -u ubuntu -- ansible-galaxy collection install \
    community.mongodb:1.6.3

# 7. Set permissions
chown -R ubuntu:ubuntu "$REPO_DIR"

# 8. Validate inventory
runuser -u ubuntu -- bash -c \
    "cd '$ANSIBLE_DIR' && ansible-inventory --graph"

echo "======================================"
echo "Controller initialization completed"
echo "Repository: $REPO_DIR"
echo "Inventory: $ANSIBLE_DIR/inventory.ini"
echo "======================================"
