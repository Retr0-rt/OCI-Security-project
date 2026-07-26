#!/bin/bash
# ==============================================================================
# Setup Script for Oracle Database 23ai Free on Oracle Linux

set -euo pipefail

# Configuration Variables
DB_PORT=1521
ORACLE_PWD="Dummy_pass_for_dummy_project"
RPM_URL="https://download.oracle.com/otn_software/linux/instantclient/234000/oracle-database-free-23ai-1.0-1.el8.x86_64.rpm"
RPM_FILE="/tmp/oracle-database-free-23ai-1.0-1.el8.x86_64.rpm"

echo "=== [Step 1/7] Updating System Packages ==="
sudo dnf update -y

echo "=== [Step 2/7] Installing Prerequisites & Pre-Install RPM ==="
# Install Oracle DB Pre-Install package (handles kernel parameters, limits, and oracle user creation)
sudo dnf install -y oracle-database-preinstall-23ai wget

echo "=== [Step 3/7] Downloading & Installing Oracle Database 23ai Free RPM ==="
if [ ! -f "$RPM_FILE" ]; then
    wget -O "$RPM_FILE" "$RPM_URL"
fi
sudo dnf localinstall -y "$RPM_FILE"

echo "=== [Step 4/7] Opening Firewall Port 1521 ==="
if systemctl is-active --quiet firewalld; then
    sudo firewall-cmd --permanent --add-port=${DB_PORT}/tcp
    sudo firewall-cmd --reload
    echo "Firewalld updated: Port ${DB_PORT}/tcp opened."
else
    echo "Firewalld is not running, skipping OS firewall configuration."
fi

echo "=== [Step 5/7] Running Oracle DB Automatic Configuration & Creation ==="
# Set the sys/system admin password in the standard installer script non-interactively
(echo "$ORACLE_PWD"; echo "$ORACLE_PWD";) | sudo /etc/init.d/oracledb_FREE-23ai configure

echo "=== [Step 6/7] Configuring Environment Variables for Oracle User ==="
sudo bash -c 'cat << "EOF" >> /home/oracle/.bashrc

# Oracle Environment Settings
export ORACLE_SID=FREE
export ORACLE_BASE=/opt/oracle
export ORACLE_HOME=/opt/oracle/product/23ai/dbhomeFree
export PATH=$PATH:$ORACLE_HOME/bin
EOF'

echo "=== [Step 7/7] Enabling and Verifying Database Service & Listener ==="
# Enable the service to start automatically on system reboot
sudo systemctl enable oracledb_FREE-23ai
sudo systemctl start oracledb_FREE-23ai

# Verify Status
sudo systemctl status oracledb_FREE-23ai --no-pager

echo "========================================================================"
echo " SUCCESS: Oracle Database 23ai Free setup completed successfully!"
echo " Service Status: Active and Listening on Port $DB_PORT"
echo " SID/Service Name: FREE / FREEPDB1"
echo "========================================================================"