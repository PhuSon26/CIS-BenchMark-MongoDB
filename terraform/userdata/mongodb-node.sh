
#!/bin/bash
set -euxo pipefail

exec > >(tee -a /var/log/mongodb-kernel-bootstrap.log) 2>&1

echo "===== MongoDB Kernel Bootstrap ====="

# 1. Update package repositories
for attempt in 1 2 3 4 5; do
    if apt-get update; then
        break
    fi

    echo "apt update failed, retrying..."
    sleep 15
done

# 2. Install AWS Linux 6.8 kernel
DEBIAN_FRONTEND=noninteractive apt-get install -y linux-image-aws-6.8

# 3. Update GRUB configuration
update-grub

# 4. Detect Advanced options submenu ID
submenu_id=$(
    grep -m1 "submenu 'Advanced options for Ubuntu'" /boot/grub/grub.cfg |
    sed -n "s/.*\\$menuentry_id_option '\\([^']*\\)'.*/\\1/p"
)

# 5. Detect installed Linux 6.8 kernel ID
kernel_id=$(
    grep -E "menuentry 'Ubuntu, with Linux 6\\.8\\.[^']*-aws'" /boot/grub/grub.cfg |
    head -n 1 |
    sed -n "s/.*\\$menuentry_id_option '\\([^']*\\)'.*/\\1/p"
)

if [ -z "$submenu_id" ] || [ -z "$kernel_id" ]; then
    echo "ERROR: Cannot find Linux 6.8 GRUB entry"
    exit 1
fi

echo "GRUB submenu: $submenu_id"
echo "Kernel entry: $kernel_id"

# 6. Configure GRUB to boot Linux 6.8
sed -i '/^GRUB_DEFAULT=/d' /etc/default/grub
echo "GRUB_DEFAULT=\"$submenu_id>$kernel_id\"" >> /etc/default/grub

update-grub

# 7. Reboot into Linux 6.8
echo "Rebooting into Linux 6.8..."
systemctl reboot
