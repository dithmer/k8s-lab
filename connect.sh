#!/bin/bash
ssh root@"$(tofu -chdir="infra/" output -json | jq -r '.salt_master_ip.value')" -i id_ed25519 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
