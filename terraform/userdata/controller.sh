#!/bin/bash
set -euxo pipefail

# Update package lists
apt-get update

# Install Ansible and Git
DEBIAN_FRONTEND=noninteractive apt-get install -y ansible git

# Clone project from GitHub
runuser -u ubuntu -- git clone \
  https://github.com/PhuSon26/CIS-BenchMark-MongoDB.git \
  /home/ubuntu/CIS-BenchMark-MongoDB