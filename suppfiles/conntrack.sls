conntrack-tools:
 pkg.installed

conntrackd:
 service:
  - running
  - enable: True
  - watch:
    - file: /etc/conntrackd/conntrackd.conf
conntrackd_conf:
 file.managed:
  - name: /etc/conntrackd/conntrackd.conf
  - source: salt://conntrackd.conf
  - template: jinja

