keepalived:
 pkg:
  - installed
 service:
  - running
  - enable: True
  - watch:
    - file: /etc/keepalived/keepalived.conf

keepalived_conf:
 file.managed:
  - name: /etc/keepalived/keepalived.conf
  - source: salt://keepalived.conf
  - template: jinja

notify_sh:
 file.managed:
  - name: /etc/keepalived/notify.sh
  - mode: 744
  - source: salt://notify.sh
  - template: jinja
