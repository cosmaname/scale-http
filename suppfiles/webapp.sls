epel-release:
 pkg:
  - installed

golang:
 pkg:
  - installed

web_app:
 file.managed:
  - name: /opt/webapp.go
  - source: salt://webapp.go
  - mode: 644

web_up:
 cmd.run:
  - name: nohup /bin/go run /opt/webapp.go >/dev/null 2>&1 &
  - prereq:
    - file: web_app
