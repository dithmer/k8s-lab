{% for name, data in salt['pillar.get']('pki', {}).items() %}
{% set file_path = '/var/lib/pki/' + name %}
{% for ending in ['cert', 'key'] %}
{% if ending in data %}
{{ file_path }}_{{ ending }}.pem:
  file.managed:
    - contents: | 
        {{ data[ending] | indent(8) }}
    - {{ 'mode: 600' if ending == 'key' else 'mode: 644' }}
    - makedirs: True
{% endif %}
{% endfor %}
{% endfor %}
