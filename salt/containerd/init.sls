# https://github.com/containerd/containerd/releases/download/v2.3.3/containerd-2.3.3-linux-amd64.tar.gz
{% set containerd_pillar = salt['pillar.get']('containerd', {}) %}
{% set containerd_version = containerd_pillar['version'] %}
{% set containerd_url = "https://github.com/containerd/containerd/releases/download/v" + containerd_version + "/containerd-" + containerd_version + "-linux-amd64.tar.gz" %}

download_containerd:
  archive.extracted:
    - name: /bin/
    - source: {{ containerd_url }}
    - source_hash: {{ containerd_url }}.sha256sum
    - options: "--strip-components=1"
    - enforce_toplevel: False

# https://github.com/opencontainers/runc/releases/download/v1.3.0-rc.1/runc.amd64
{% set runc_pillar = salt['pillar.get']('runc', {}) %}
{% set runc_version = runc_pillar['version'] %}
{% set runc_url = "https://github.com/opencontainers/runc/releases/download/v" + runc_version + "/runc.amd64" %}
download_runc:
  file.managed:
    - name: /usr/local/bin/runc
    - source: {{ runc_url }}
    - skip_verify: True
    - mode: 755
    - user: root
    - group: root

{% set crictl_pillar = salt['pillar.get']('crictl', {}) %}
{% set crictl_version = crictl_pillar['version'] %}
{% set crictl_url = "https://github.com/kubernetes-sigs/cri-tools/releases/download/v" + crictl_version + "/crictl-v" + crictl_version + "-linux-amd64.tar.gz" %}
download_crictl:
  archive.extracted:
    - name: /usr/local/bin/
    - enforce_toplevel: False
    - source: {{ crictl_url }}
    - skip_verify: True

{% set containerd_config_dir = "/etc/containerd" %}

{{ containerd_config_dir }}/config.toml:
  file.managed:
    - contents: |
        version = 2

        [plugins."io.containerd.grpc.v1.cri"]
          [plugins."io.containerd.grpc.v1.cri".containerd]
            snapshotter = "overlayfs"
            default_runtime_name = "runc"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
            runtime_type = "io.containerd.runc.v2"
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            SystemdCgroup = true
        [plugins."io.containerd.grpc.v1.cri".cni]
          bin_dir = "/opt/cni/bin"
          conf_dir = "/etc/cni/net.d"
    - makedirs: True
    - user: root
    - group: root
    - mode: 644

/etc/systemd/system/containerd.service:
  file.managed:
    - contents: |
        [Unit]
        Description=containerd container runtime
        Documentation=https://containerd.io
        After=network.target

        [Service]
        ExecStartPre=/sbin/modprobe overlay
        ExecStart=/bin/containerd
        Restart=always
        RestartSec=5
        Delegate=yes
        KillMode=process
        OOMScoreAdjust=-999
        LimitNOFILE=1048576
        LimitNPROC=infinity
        LimitCORE=infinity

        [Install]
        WantedBy=multi-user.target

containerd_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/containerd.service

containerd_service:
  service.running:
    - name: containerd
    - enable: True
    - watch:
      - file: /etc/systemd/system/containerd.service
      - file: {{ containerd_config_dir }}/config.toml

