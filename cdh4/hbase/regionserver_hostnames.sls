# Write all regionserver hosts to /etc/hosts
{% set regionservers = salt['publish.publish']('G@stack_id:' ~ grains.stack_id ~ ' and G@roles:cdh4.hbase.regionserver', 'grains.items', '', 'compound').items() %}
{% if regionservers %}
append_regionservers_etc_hosts:
  file:
    - append
    - name: /etc/hosts
    - text:
{% for host, items in regionservers %}
      - {{ items['ip_interfaces']['eth0'][0] }} {{ items['fqdn'] }}
{% endfor %}
{% endif %}
