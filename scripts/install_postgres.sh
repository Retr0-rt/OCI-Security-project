#!/bin/bash
set -euo pipefail

###############################################################################
# PostgreSQL Installation Script
# Oracle Linux 8 (ARM64)
###############################################################################

DB_NAME="securedb"
DB_USER="secureuser"
DB_PASSWORD="DUMMY_PASS_FOR_DUMMY_DB"

APP_SUBNET="10.0.2.0/24"

echo "========== Updating system =========="
dnf -y update

echo "========== Installing PostgreSQL =========="
dnf install -y postgresql-server postgresql

echo "========== Initializing database =========="
if [ ! -f /var/lib/pgsql/data/PG_VERSION ]; then
    postgresql-setup --initdb
fi

echo "========== Configuring PostgreSQL =========="

PG_CONF="/var/lib/pgsql/data/postgresql.conf"
PG_HBA="/var/lib/pgsql/data/pg_hba.conf"

# Listen on all interfaces (OCI NSGs control access)
sed -i "s/^#listen_addresses =.*/listen_addresses = '*'/" "$PG_CONF"

# Optional: keep default PostgreSQL port
# sed -i "s/^#port = 5432/port = 5432/" "$PG_CONF"

# Allow connections only from the private subnet
grep -q "$APP_SUBNET" "$PG_HBA" || cat <<EOF >> "$PG_HBA"

# Application subnet
host    all    all    $APP_SUBNET    scram-sha-256
EOF

echo "========== Enabling PostgreSQL =========="
systemctl enable postgresql
systemctl restart postgresql

echo "========== Creating database =========="

sudo -u postgres psql <<EOF
DO
\$\$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE rolname = '$DB_USER'
   ) THEN
      CREATE ROLE $DB_USER LOGIN PASSWORD '$DB_PASSWORD';
   END IF;
END
\$\$;

SELECT 'CREATE DATABASE $DB_NAME OWNER $DB_USER'
WHERE NOT EXISTS (
    SELECT FROM pg_database
    WHERE datname = '$DB_NAME'
)\gexec

GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOF

echo "========== PostgreSQL Status =========="
systemctl --no-pager status postgresql

echo "========== Listening Socket =========="
ss -ltn | grep 5432 || true

echo "========== Installation Complete =========="
echo "Database : $DB_NAME"
echo "User     : $DB_USER"
echo "Port     : 5432"