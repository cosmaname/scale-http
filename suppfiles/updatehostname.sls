updatehostname.sls
"Update my name {{ grains['id'] }}":
  network.system:
   - name: {{ grains['id'] }}
   - enabled: True
   - hostname: {{ grains['id'] }}
   - apply_hostname: True
