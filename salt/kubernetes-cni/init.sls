{% set cni_net_config_dir = '/etc/cni/net.d' %}
{% set cni_bin_dir = '/opt/cni/bin' %}

{{ cni_net_config_dir }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

{{ cni_bin_dir }}:
  file.directory:
    - makedirs: True
    - user: root
    - group: root
    - mode: 755

{% set kubernetes_node_pillar = salt['pillar.get']('kubernetes:node', {}) %}

{% set cni_plugins_pillar = salt['pillar.get']('kubernetes-cni', {}) %}
{% set cni_plugins_version = cni_plugins_pillar['version'] %} # fail if version is not set
{% set cni_plugins_download_url = 'https://github.com/containernetworking/plugins/releases/download/v' + cni_plugins_version + '/cni-plugins-linux-amd64-v' + cni_plugins_version + '.tgz' %}

download_cni_plugins:
  archive.extracted:
    - name: {{ cni_bin_dir }}
    - source: {{ cni_plugins_download_url }}
    - source_hash: {{ cni_plugins_download_url }}.sha256

# bride conf
{{ cni_net_config_dir }}/10-bridge.conf:
  file.managed:
    - contents: |
        {
          "cniVersion": "1.0.0",
          "name": "bridge",
          "type": "bridge",
          "bridge": "cni0",
          "isGateway": true,
          "ipMasq": true,
          "ipam": {
            "type": "host-local",
            "ranges": [
              [{"subnet": "{{ kubernetes_node_pillar["subnet"] }}" }]
            ],
            "routes": [{"dst": "0.0.0.0/0"}]
          }
        }

# loopback conf
{{ cni_net_config_dir }}/99-loopback.conf:
  file.managed:
    - contents: |
        {
          "cniVersion": "1.1.0",
          "name": "lo",
          "type": "loopback"
        }

# modprobe for bridge and loopback
load_kernel_modules:
  cmd.run:
    - name: modprobe br-netfilter
  file.managed:
    - name: /etc/modules-load.d/k8s-cni.conf
    - contents: |
        br-netfilter

/etc/sysctl.d/k8s-cni.conf:
  file.managed:
    - contents: |
        net.bridge.bridge-nf-call-iptables = 1
        net.bridge.bridge-nf-call-ip6tables = 1
  cmd.run:
    - name: sysctl -p /etc/sysctl.d/k8s-cni.conf
    - onchanges:
      - file: /etc/sysctl.d/k8s-cni.conf
