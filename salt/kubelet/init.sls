{% set kubelet_pillar = salt['pillar.get']('kubelet', {}) %}
{% set kubelet_version = kubelet_pillar['version'] %}
{% set kubelet_url = "https://dl.k8s.io/v" + kubelet_version + "/bin/linux/amd64/kubelet" %}
{% set pki_dir = '/var/lib/pki' %}

/usr/local/bin/kubelet:
  file.managed:
    - source: {{ kubelet_url }}
    - mode: 755
    - skip_verify: True
    - user: root
    - group: root

{% set kubelet_config_dir = "/var/lib/kubelet" %}
{% set service_name = "kubelet" %}
{% set kubelet_service_file = "/etc/systemd/system/" + service_name + ".service" %}

{% set control_plane_hostname = salt['pillar.get']('kubernetes:control_plane_hostname') %}

{{ kubelet_config_dir }}/kubelet-config.yaml:
  file.managed:
    - makedirs: True
    - mode: 644
    - contents: |
        kind: KubeletConfiguration
        apiVersion: kubelet.config.k8s.io/v1beta1
        address: "0.0.0.0"
        authentication:
          anonymous:
            enabled: false
          webhook:
            enabled: true
          x509:
            clientCAFile: "/var/lib/pki/ca_cert.pem"
        authorization:
          mode: Webhook
        cgroupDriver: systemd
        containerRuntimeEndpoint: "unix:///var/run/containerd/containerd.sock"
        enableServer: true
        failSwapOn: false
        maxPods: 16
        memorySwap:
          swapBehavior: NoSwap
        port: 10250
        clusterDNS:
          - 10.0.0.10
        clusterDomain: "cluster.local"
        resolvConf: "/run/systemd/resolve/resolv.conf"
        registerNode: true
        runtimeRequestTimeout: "15m"
        tlsCertFile: "/var/lib/pki/kubelet_cert.pem"
        tlsPrivateKeyFile: "/var/lib/pki/kubelet_key.pem"

/opt/kubernetes/generate_kubeconfig_kubelet.sh:
  file.managed:
    - makedirs: True
    - mode: 755
    - contents: |
        {
          kubectl config set-cluster kubernetes \
            --certificate-authority={{ pki_dir }}/ca_cert.pem \
            --embed-certs=true \
            --server=https://{{ control_plane_hostname }}.kubernetes.local:6443 \
            --kubeconfig={{ kubelet_config_dir }}/kubelet.kubeconfig

          kubectl config set-credentials system:node:{{ grains['id'] }} \
            --client-certificate={{ pki_dir }}/kubelet_cert.pem \
            --client-key={{ pki_dir }}/kubelet_key.pem \
            --embed-certs=true \
            --kubeconfig={{ kubelet_config_dir }}/kubelet.kubeconfig

          kubectl config set-context default \
            --cluster=kubernetes \
            --user=system:node:{{ grains['id'] }}\
            --kubeconfig={{ kubelet_config_dir }}/kubelet.kubeconfig

          kubectl config use-context default \
            --kubeconfig={{ kubelet_config_dir }}/kubelet.kubeconfig
        }
  cmd.run: []

{{ kubelet_service_file }}:
  file.managed:
    - contents: |
        [Unit]
        Description=Kubernetes Kubelet
        Documentation=https://github.com/kubernetes/kubernetes
        After=containerd.service
        Requires=containerd.service

        [Service]
        ExecStart=/usr/local/bin/kubelet \
          --config={{ kubelet_config_dir }}/kubelet-config.yaml \
          --kubeconfig={{ kubelet_config_dir }}/kubelet.kubeconfig \
          --v=2
        Restart=on-failure
        RestartSec=5

        [Install]
        WantedBy=multi-user.target

kubelet_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ kubelet_service_file }}

{{ service_name }}:
  service.running:
    - enable: True
    - watch:
      - file: {{ kubelet_service_file }}
