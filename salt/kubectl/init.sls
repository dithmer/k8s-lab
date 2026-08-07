# https://dl.k8s.io/v1.36.2/bin/linux/amd64/kubectl
{% set service_name = 'kubectl' %}
{% set kubectl_pillar = salt['pillar.get']('kubectl', {}) %}
{% set kubectl_version = kubectl_pillar['version'] %} # fail if version is not set
{% set kubectl_download_url = 'https://dl.k8s.io/v' + kubectl_version + '/bin/linux/amd64/kubectl' %}

{% set kubernetes_lib = '/var/lib/kubernetes' %}
{% set pki_dir = '/var/lib/pki' %}

download_kubectl:
  file.managed:
    - name: /usr/local/bin/kubectl
    - source: {{ kubectl_download_url }}
    - source_hash: {{ kubectl_download_url }}.sha256
    - mode: 755
    - makedirs: True
