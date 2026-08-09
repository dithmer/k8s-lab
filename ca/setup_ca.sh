#!/bin/bash

# Create CA key and certificate
{
  openssl genrsa -out ca.key 4096
  openssl req -x509 -new -sha512 -noenc \
    -key ca.key -days 3653 \
    -config ca.conf \
    -out ca.crt
}

# Create keys, CSRs, and certificates for all components
certs=(
  # Control Plane
  "kube-api-server"
  "kube-controller-manager"

  # Node
  "kube-proxy"
  "kube-scheduler"
)

for i in ${certs[*]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
    -config "${i}.conf" \
    -out "${i}.csr"

  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
done

account_certs=("service-accounts" "admin")

for i in ${account_certs[*]}; do
  openssl genrsa -out "${i}.key" 4096

  openssl req -new -key "${i}.key" -sha256 \
    -config "users.conf" -section "${i}" \
    -out "${i}.csr"

  openssl x509 -req -days 3653 -in "${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "${i}.crt"
  done


node_certs=("node-0" "node-1")

for i in ${node_certs[*]}; do
  # config contains {{ node_name }} placeholder, replace it with the actual node name
  sed "s/{{ node_name }}/${i}/g" node.conf > "node_${i}.conf"

  openssl genrsa -out "nodee_${i}.key" 4096

  openssl req -new -key "nodee_${i}.key" -sha256 \
    -config "node_${i}.conf" \
    -out "node_${i}.csr"

  openssl x509 -req -days 3653 -in "node_${i}.csr" \
    -copy_extensions copyall \
    -sha256 -CA "ca.crt" \
    -CAkey "ca.key" \
    -CAcreateserial \
    -out "node_${i}.crt"
done
