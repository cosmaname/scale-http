ntp:
 pkg.installed
ntpd:
 service:
  - running
  - enable: True
  - watch:
    - file: /etc/ntp.conf
ntp_conf:
 file.managed:
  - name: /etc/ntp.conf
  - source: salt://ntp.conf
sysctl_conf:
 file.managed:
  - name: /etc/sysctl.d/90-custom.conf
  - source: salt://90-custom.conf

