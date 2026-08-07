# https://dl.k8s.io/v1.36.2/bin/linux/amd64/kube-controller-manager
{% set service_name = 'kube-controller-manager' %}
{% set kube_controller_manager_pillar = salt['pillar.get']('kube-controller-manager', {}) %}
{% set kube_controller_manager_version = kube_controller_manager_pillar['version'] %} # fail if version is not set
{% set kube_controller_manager_download_url = 'https://dl.k8s.io/v' + kube_controller_manager_version + '/bin/linux/amd64/kube-controller-manager' %}

{% set kubernetes_lib = '/var/lib/kubernetes' %}
{% set pki_dir = '/var/lib/pki' %}

download_kube_controller_manager:
  file.managed:
    - name: /usr/local/bin/kube-controller-manager
    - source: {{ kube_controller_manager_download_url }}
    - source_hash: {{ kube_controller_manager_download_url }}.sha256
    - mode: 755
    - makedirs: True

/opt/kubernetes/generate_kubeconfig_controller.sh:
  file.managed:
    - makedirs: True
    - mode: 755
    - contents: |
        {
          kubectl config set-cluster kubernetes \
            --certificate-authority={{ pki_dir }}/ca_cert.pem \
            --embed-certs=true \
            --server=https://server.kubernetes.local:6443 \
            --kubeconfig={{ kubernetes_lib }}/kube-controller-manager.kubeconfig

          kubectl config set-credentials system:kube-controller-manager \
            --client-certificate={{ pki_dir }}/kube-controller-manager_cert.pem \
            --client-key={{ pki_dir }}/kube-controller-manager_key.pem \
            --embed-certs=true \
            --kubeconfig={{ kubernetes_lib }}/kube-controller-manager.kubeconfig

          kubectl config set-context default \
            --cluster=kubernetes \
            --user=system:kube-controller-manager \
            --kubeconfig={{ kubernetes_lib }}/kube-controller-manager.kubeconfig

          kubectl config use-context default \
            --kubeconfig={{ kubernetes_lib }}/kube-controller-manager.kubeconfig
        }
  cmd.run: []

/etc/systemd/system/{{ service_name }}.service:
  file.managed:
    - contents: |
        [Unit]
        Description=Kubernetes Controller Manager
        Documentation=https://github.com/kubernetes/kubernetes

        [Service]
        ExecStart=/usr/local/bin/kube-controller-manager \
          --bind-address=0.0.0.0 \
          --cluster-cidr=10.200.0.0/16 \
          --cluster-name=kubernetes \
          --cluster-signing-cert-file=/var/lib/pki/ca_cert.pem \
          --cluster-signing-key-file=/var/lib/pki/ca_key.pem \
          --kubeconfig=/var/lib/kubernetes/kube-controller-manager.kubeconfig \
          --root-ca-file=/var/lib/pki/ca_cert.pem \
          --service-account-private-key-file=/var/lib/pki/service-accounts_key.pem \
          --service-cluster-ip-range=10.32.0.0/24 \
          --use-service-account-credentials=true \
          --v=2
        Restart=on-failure
        RestartSec=5

        [Install]
        WantedBy=multi-user.target

kube-controller-manager_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/{{ service_name }}.service

{{ service_name }}:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/{{ service_name }}.service
