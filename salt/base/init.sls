'install base packages':
  pkg.installed:
    - pkgs:
      {% for package in pillar.get('packages', []) %}
      - {{ package }}
      {% endfor %}

hostnames_in_hosts:
  file.blockreplace:
    - name: /etc/hosts
    - append_if_not_found: True
    - marker_start: "# BEGIN SALT MANAGED HOSTNAMES"
    - marker_end: "# END SALT MANAGED HOSTNAMES"
    - content: | # from salt mine
        {% for hostname, ip in salt['mine.get']('*', 'network.ip_addrs').items() %}
        {{ ip[0] }} {{ hostname }}.kubernetes.local
        {% endfor %}
