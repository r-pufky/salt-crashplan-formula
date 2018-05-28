{%- from "crashplan/map.jinja" import crashplan with context -%}

{%- set staging = crashplan.staging_dir ~ '/' ~ crashplan.release.version -%}
{%- set linux_install = staging ~ crashplan.install_script ~ ' -q' -%}
{%- set linux_remove = staging ~ crashplan.remove_script ~ ' -q -i ' ~ crashplan.install_dir -%}


crashplan_package_dependencies:
  pkg.installed:
    - pkgs:
{%- for pkg in crashplan.package_dependencies %}
      - {{ pkg }}
{%- endfor %}

crashplan_staging_dir:
  file.directory:
    - name: {{ staging }}
    - user: root
    - group: root
    - dir_mode: 0750
    - file_mode: 0640
    - makedirs: True
    - recurse:
      - user
      - group
      - mode

# As long as minion cache exists, file will not be re-downloaded.
copy_binary_archive:
  archive.extracted:
    - name: {{ staging }}
    - source: salt://crashplan/files/{{ crashplan.binary.linux }}
    - source_hash: {{ crashplan.binary.linux_hash }}
    - source_hash_update: True
    - user: root
    - group: root
    - dir_mode: 0750
    - file_mode: 0640
    - require:
      - file: crashplan_staging_dir

crashplan_remove_current:
  cmd.run:
    - onlyif: test -d {{ crashplan.install_dir }}
    - name: {{ linux_remove }}
    - stdin: 'yes\n'
    - hide_output: True
    - check_cmd:
      - /bin/true
    - onchanges:
      - archive: copy_binary_archive

crashplan_install_on_new_packages:
  cmd.run:
    - name: {{ linux_install }}
    - hide_output: True
    - require:
      - pkg: crashplan_package_dependencies
      - cmd: crashplan_remove_current
    - onchanges:
      - archive: copy_binary_archive

crashplan_service:
  service.running:
    - name: {{ crashplan.service }}
    - enable: True
