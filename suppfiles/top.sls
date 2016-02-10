base:
 '*':
 {% if grains['kernel'] == 'Linux' %}
  - common
 {% endif %}
 'kdct*':
  - tcpdump:
     pkg.installed
  - keepalive
  - conntrack
 'nginx*':
  - nginx
 'go*':
  - webapp
