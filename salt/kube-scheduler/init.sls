# https://dl.k8s.io/v1.36.2/bin/linux/amd64/kube-scheduler
{% set service_name = 'kube-scheduler' %}
{% set kube_scheduler_pillar = salt['pillar.get']('kube-scheduler', {}) %}
{% set kube_scheduler_version = kube_scheduler_pillar['version'] %} # fail if version is not set
{% set kube_scheduler_download_url = 'https://dl.k8s.io/v' + kube_scheduler_version + '/bin/linux/amd64/kube-scheduler' %}

{% set kubernetes_lib = '/var/lib/kubernetes' %}
{% set kubernetes_config_dir = '/etc/kubernetes/config' %}
{% set pki_dir = '/var/lib/pki' %}

{% set control_plane_hostname = salt['pillar.get']('kubernetes:control_plane_hostname') %}

download_kube_scheduler:
  file.managed:
    - name: /usr/local/bin/kube-scheduler
    - source: {{ kube_scheduler_download_url }}
    - source_hash: {{ kube_scheduler_download_url }}.sha256
    - mode: 755
    - makedirs: True

{{ kubernetes_config_dir }}/kube-scheduler.yaml:
  file.managed:
    - makedirs: True
    - contents: |
        apiVersion: kubescheduler.config.k8s.io/v1
        kind: KubeSchedulerConfiguration
        clientConnection:
          kubeconfig: "/var/lib/kubernetes/kube-scheduler.kubeconfig"
        leaderElection:
          leaderElect: true

/opt/kubernetes/generate_kubeconfig_scheduler.sh:
  file.managed:
    - makedirs: True
    - mode: 755
    - contents: |
        {
          kubectl config set-cluster kubernetes \
            --certificate-authority={{ pki_dir }}/ca_cert.pem \
            --embed-certs=true \
            --server=https://{{ control_plane_hostname }}.kubernetes.local:6443 \
            --kubeconfig={{ kubernetes_lib }}/kube-scheduler.kubeconfig

          kubectl config set-credentials system:kube-scheduler \
            --client-certificate={{ pki_dir }}/kube-scheduler_cert.pem \
            --client-key={{ pki_dir }}/kube-scheduler_key.pem \
            --embed-certs=true \
            --kubeconfig={{ kubernetes_lib }}/kube-scheduler.kubeconfig

          kubectl config set-context default \
            --cluster=kubernetes \
            --user=system:kube-scheduler \
            --kubeconfig={{ kubernetes_lib }}/kube-scheduler.kubeconfig

          kubectl config use-context default \
            --kubeconfig={{ kubernetes_lib }}/kube-scheduler.kubeconfig
        }
  cmd.run: []

/etc/systemd/system/{{ service_name }}.service:
  file.managed:
    - contents: |
        [Unit]
        Description=Kubernetes Scheduler
        Documentation=https://github.com/kubernetes/kubernetes

        [Service]
        ExecStart=/usr/local/bin/kube-scheduler \
          --config={{ kubernetes_config_dir }}/kube-scheduler.yaml \
          --v=2
        Restart=on-failure
        RestartSec=5

        [Install]
        WantedBy=multi-user.target

kube-scheduler_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/{{ service_name }}.service

{{ service_name }}:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/{{ service_name }}.service
