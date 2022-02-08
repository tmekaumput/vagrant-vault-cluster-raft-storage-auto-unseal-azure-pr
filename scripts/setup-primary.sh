#!/bin/bash

SHARED_DIR=${1}

export VAULT_TOKEN=$(sudo cat ${SHARED_DIR}/root_token-vault)

vault policy write superuser -<<EOF
path "*" {
  capabilities = ["create", "read", "update", "delete", "list", "sudo"]
}
EOF

vault auth enable userpass

vault write auth/userpass/users/tester password="changeme" policies="superuser"

# Enable primary cluster
vault write -f sys/replication/performance/primary/enable

# Delay
sleep 10

# Setup activation token
vault write sys/replication/performance/primary/secondary-token id=$(uuidgen) -format=json | jq -r '.wrap_info.token' | sudo tee ${SHARED_DIR}/../activation-token.txt >/dev/null

