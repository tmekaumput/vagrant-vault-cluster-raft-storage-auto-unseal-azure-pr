#!/bin/bash

SHARED_DIR=${1}

export VAULT_TOKEN=$(sudo cat ${SHARED_DIR}/root_token-vault)

vault write sys/replication/performance/secondary/enable token=$(sudo cat ${SHARED_DIR}/../activation-token.txt)
