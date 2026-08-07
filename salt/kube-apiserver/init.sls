# https://dl.k8s.io/v1.36.2/bin/linux/amd64/kube-apiserver
{% set service_name = 'kube-apiserver' %}
{% set kube_apiserver_pillar = salt['pillar.get']('kube-apiserver', {}) %}
{% set kube_apiserver_version = kube_apiserver_pillar['version'] %} # fail if version is not set
{% set kube_apiserver_download_url = 'https://dl.k8s.io/v' + kube_apiserver_version + '/bin/linux/amd64/kube-apiserver' %}

download_kube_apiserver:
  file.managed:
    - name: /usr/local/bin/kube-apiserver
    - source: {{ kube_apiserver_download_url }}
    - source_hash: {{ kube_apiserver_download_url }}.sha256
    - mode: 755
    - makedirs: True

/etc/systemd/system/{{ service_name }}.service:
  file.managed:
    - contents: |
          [Unit]
          Description=Kubernetes API Server
          Documentation=https://github.com/kubernetes/kubernetes

          [Service]
          ExecStart=/usr/local/bin/kube-apiserver \
            --allow-privileged=true \
            --audit-log-maxage=30 \
            --audit-log-maxbackup=3 \
            --audit-log-maxsize=100 \
            --audit-log-path=/var/log/audit.log \
            --authorization-mode=Node,RBAC \
            --bind-address=0.0.0.0 \
            --client-ca-file=/var/lib/pki/ca_cert.pem \
            --enable-admission-plugins=NamespaceLifecycle,NodeRestriction,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota \
            --etcd-servers=http://127.0.0.1:2379 \
            --event-ttl=1h \
            #--encryption-provider-config=/var/lib/kubernetes/encryption-config.yaml \
            --kubelet-certificate-authority=/var/lib/pki/ca_cert.pem \
            --kubelet-client-certificate=/var/lib/pki/kube-apiserver_cert.pem \
            --kubelet-client-key=/var/lib/pki/kube-apiserver_key.pem \
            --runtime-config='api/all=true' \
            --service-account-key-file=/var/lib/pki/service-accounts_cert.pem \
            --service-account-signing-key-file=/var/lib/pki/service-accounts_key.pem \
            --service-account-issuer=https://server.kubernetes.local:6443 \
            --service-node-port-range=30000-32767 \
            --tls-cert-file=/var/lib/pki/kube-apiserver_cert.pem \
            --tls-private-key-file=/var/lib/pki/kube-apiserver_key.pem \
            --v=2
          Restart=on-failure
          RestartSec=5

          [Install]
          WantedBy=multi-user.target

kube-apiserver_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/{{ service_name }}.service

{{ service_name }}:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/{{ service_name }}.service
