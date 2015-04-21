{% if pillar.get('enable_cluster_monitoring', '').lower() == 'true' %}
/etc/kubernetes/addons/cluster-monitoring:
  file.recurse:
    - source: salt://kube-addons/cluster-monitoring
    - include_pat: E@^.+\.yaml$
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644
{% endif %}

{% if pillar.get('enable_cluster_dns', '').lower() == 'true' %}
/etc/kubernetes/addons/dns/skydns-svc.yaml:
  file.managed:
    - source: salt://kube-addons/dns/skydns-svc.yaml.in
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True

/etc/kubernetes/addons/dns/skydns-rc.yaml:
  file.managed:
    - source: salt://kube-addons/dns/skydns-rc.yaml.in
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True
{% endif %}

{% if pillar.get('enable_node_logging', '').lower() == 'true'
   and pillar.get('logging_destination').lower() == 'elasticsearch'
   and pillar.get('enable_cluster_logging', '').lower() == 'true' %}
/etc/kubernetes/addons/fluentd-elasticsearch:
  file.recurse:
    - source: salt://kube-addons/fluentd-elasticsearch
    - include_pat: E@^.+\.yaml$
    - user: root
    - group: root
    - dir_mode: 755
    - file_mode: 644

/etc/kubernetes/addons/fluentd-elasticsearch/es-controller.yaml:
  file.managed:
    - source: salt://kube-addons/fluentd-elasticsearch/es-controller.yaml.in
    - template: jinja
    - group: root
    - dir_mode: 755
    - makedirs: True
{% endif %}

{% if grains['os_family'] == 'RedHat' %}
{% set environment_file = '/etc/sysconfig/kube-addons' %}
{% else %}
{% set environment_file = '/etc/default/kube-addons' %}
{% endif %}

{{ environment_file }}:
  file.managed:
    - source: salt://kube-addons/default
    - template: jinja
    - user: root
    - group: root
    - mode: 644

/etc/kubernetes/kube-addons.sh:
  file.managed:
    - source: salt://kube-addons/kube-addons.sh
    - user: root
    - group: root
    - mode: 755

{% if grains['os_family'] == 'RedHat' %}

/usr/lib/systemd/system/kube-addons.service:
  file.managed:
    - source: salt://kube-addons/kube-addons.service
    - user: root
    - group: root

{% else %}

/etc/init.d/kube-addons:
  file.managed:
    - source: salt://kube-addons/initd
    - user: root
    - group: root
    - mode: 755

{% endif %}

kube-addons:
  service.running:
    - enable: True