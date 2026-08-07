'install base packages':
  pkg.installed:
    - pkgs:
      {% for package in pillar.get('packages', []) %}
      - {{ package }}
      {% endfor %}
