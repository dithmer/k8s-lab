{% set kube_proxy_pillar = salt['pillar.get']('kube-proxy', {}) %}
{% set kube_proxy_version = kube_proxy_pillar['version'] %}
{% set kube_proxy_url = "https://dl.k8s.io/v" + kube_proxy_version + "/bin/linux/amd64/kube-proxy" %}
{% set pki_dir = '/var/lib/pki' %}

/usr/local/bin/kube-proxy:
  file.managed:
    - source: {{ kube_proxy_url }}
    - mode: 755
    - skip_verify: True
    - user: root
    - group: root

{% set kube_proxy_config_dir = "/var/lib/kube-proxy" %}
{% set service_name = "kube-proxy" %}
{% set kube_proxy_service_file = "/etc/systemd/system/" + service_name + ".service" %}

{{ kube_proxy_config_dir }}/kube-proxy-config.yaml:
  file.managed:
    - makedirs: True
    - mode: 644
    # TODO: Make clusterCIDR configurable via pillar
    - contents: |
        kind: KubeProxyConfiguration
        apiVersion: kubeproxy.config.k8s.io/v1alpha1
        clientConnection:
          kubeconfig: "/var/lib/kube-proxy/kube-proxy.kubeconfig"
        mode: "iptables"
        clusterCIDR: "10.200.0.0/16"

/opt/kubernetes/generate_kubeconfig_kube-proxy.sh:
  file.managed:
    - makedirs: True
    - mode: 755
    - contents: |
        {
          kubectl config set-cluster kubernetes \
            --certificate-authority={{ pki_dir }}/ca_cert.pem \
            --embed-certs=true \
            --server=https://server.kubernetes.local:6443 \
            --kubeconfig={{ kube_proxy_config_dir }}/kube-proxy.kubeconfig

          kubectl config set-credentials system:kube-proxy  \
            --client-certificate={{ pki_dir }}/kube-proxy_cert.pem \
            --client-key={{ pki_dir }}/kube-proxy_key.pem \
            --embed-certs=true \
            --kubeconfig={{ kube_proxy_config_dir }}/kube-proxy.kubeconfig

          kubectl config set-context default \
            --cluster=kubernetes \
            --user=system:kube-proxy \
            --kubeconfig={{ kube_proxy_config_dir }}/kube-proxy.kubeconfig

          kubectl config use-context default \
            --kubeconfig={{ kube_proxy_config_dir }}/kube-proxy.kubeconfig
        }
  cmd.run: []

{{ kube_proxy_service_file }}:
  file.managed:
    - contents: |
        [Unit]
        Description=Kubernetes Kube Proxy
        Documentation=https://github.com/kubernetes/kubernetes

        [Service]
        ExecStart=/usr/local/bin/kube-proxy \
          --config=/var/lib/kube-proxy/kube-proxy-config.yaml
        Restart=on-failure
        RestartSec=5

        [Install]
        WantedBy=multi-user.target

kube_proxy_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: {{ kube_proxy_service_file }}

{{ service_name }}:
  service.running:
    - enable: True
    - watch:
      - file: {{ kube_proxy_service_file }}
