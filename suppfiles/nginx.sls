nginx:
 pkg:
  - installed
 service:
  - running
  - enable: True
  - watch:
    - file: /etc/nginx/nginx.conf

nginx_conf:
 file.managed:
  - name: /etc/nginx/nginx.conf
  - source: salt://nginx.conf
  - template: jinja
