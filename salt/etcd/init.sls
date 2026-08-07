{% set service_name = 'etcd' %}
{% set etcd_pillar = salt['pillar.get']('etcd', {}) %}
{% set etcd_version = etcd_pillar['version'] %} # fail if version is not set
{% set etcd_download_url = 'https://github.com/etcd-io/etcd/releases/download/v' + etcd_version + '/etcd-v' + etcd_version + '-linux-amd64.tar.gz' %}

extract_etcd:
  archive.extracted:
    - name: /usr/local/bin
    - source: {{ etcd_download_url }}
    - archive_format: tar
    - skip_verify: True
    - if_missing: /usr/local/bin/etcd
    - keep: false
    - options: "--strip-components=1"
    - enforce_toplevel: False

/var/lib/etcd:
  file.directory:
    - mode: 755

/etc/etcd:
  file.directory:
    - mode: 755

/etc/systemd/system/etcd.service:
  file.managed:
    - contents: |
        [Unit]
        Description=etcd
        Documentation=https://github.com/etcd-io/etcd

        [Service]
        Type=notify
        ExecStart=/usr/local/bin/etcd \
          --name controller \
          --initial-advertise-peer-urls http://127.0.0.1:2380 \
          --listen-peer-urls http://127.0.0.1:2380 \
          --listen-client-urls http://127.0.0.1:2379 \
          --advertise-client-urls http://127.0.0.1:2379 \
          --initial-cluster-token etcd-cluster-0 \
          --initial-cluster controller=http://127.0.0.1:2380 \
          --initial-cluster-state new \
          --data-dir=/var/lib/etcd
        Restart=on-failure
        RestartSec=5

        [Install]
        WantedBy=multi-user.target

etcd_daemon_reload:
  cmd.run:
    - name: systemctl daemon-reload
    - onchanges:
      - file: /etc/systemd/system/etcd.service

etcd:
  service.running:
    - enable: True
    - watch:
      - file: /etc/systemd/system/etcd.service
