#!/bin/bash
set -euo pipefail
cd "$(dirname "$(realpath "$0")")" || exit 1

prepare_pillar() {
  local arg name mode

  if [[ $# -eq 0 ]]; then
    echo "Usage: prepare_pillar <name1> [<name2>:cert ...]" >&2
    return 1
  fi

  {
    echo "pki:"
    for arg in "$@"; do
      # By default, assume we want both, and the name is the full argument
      mode="both"
      name="$arg"
      # If the argument ends with ':cert', change mode and strip the suffix
      if [[ "$arg" == *":cert" ]]; then
        mode="cert"
        name="${arg%:cert}"
      fi
      echo "  ${name}:"
      # Add KEY if in "both" mode AND the file exists
      if [[ "$mode" == "both" ]] && [[ -f "${name}.key" ]]; then
        echo "    key: |"
        sed 's/^/      /' "${name}.key"
      fi
      # Add CERT if the file exists
      if [[ -f "${name}.crt" ]]; then
        echo "    cert: |"
        sed 's/^/      /' "${name}.crt"
      fi
    done
  }
}

gen_key_and_cert() {
  local name="$1"
  local conf="$2"
  local section="${3:-req}"

  openssl genrsa -out "${name}.key" 4096

  openssl req -new -key "${name}.key" -sha256 \
    -config "${conf}" -section "${section}" \
    -out "${name}.csr"

  openssl x509 -req -days 3653 -in "${name}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "${name}.crt"
}

gen_ca() {
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ca.conf \
    -out ca.crt
}

amount_of_nodes="${1:-1}"
if [[ ! "$amount_of_nodes" =~ ^-?[0-9]+$ ]] || [ "$amount_of_nodes" -lt 1 ]; then
  echo "Amount of nodes must be at least 1" >&2
  exit 1
fi
amount_of_nodes=$((amount_of_nodes - 1))

gen_ca

# Create keys, CSRs, and certificates for all components
certs=("kube-api-server" "kube-controller-manager" "kube-proxy" "kube-scheduler")
for i in ${certs[*]}; do
  gen_key_and_cert "${i}" "${i}.conf"
done

account_certs=("service-accounts" "admin")
for i in ${account_certs[*]}; do
  gen_key_and_cert "${i}" "users.conf" "${i}"
done
prepare_pillar "ca" "kube-api-server" "service-accounts" "kube-controller-manager" "kube-scheduler" "admin" > control_plane_pillar.yaml


for i in $(seq 0 "$amount_of_nodes"); do
  i="node-${i}"
  # config contains {{ node_name }} placeholder, replace it with the actual node name
  sed "s/{{ node_name }}/${i}/g" node.conf > "node_${i}.conf"

  gen_key_and_cert "$i" "node_${i}.conf"

  prepare_pillar "ca":cert "$i" | sed 's/'"${i}"'/kubelet/g' > "${i}"_pillar.yaml
done

rm -rf -- *.csr *.srl *.key *.crt node_*.conf
