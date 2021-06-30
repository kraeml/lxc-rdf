# LXC RDF InSpec Profile

Hier wird der LXC-Stack der Rudolf Diesel Fachschule getestet.

## Durchführen

### Alle Tests

```bash
inspec exec https://github.com/kraeml/lxc-rdf.git
```

ACHTUNG: Es wird nur der localhost (Vagrant) überprüft. Zur Zeit lxc_net und machines.

### LXC Netzwerk

```bash
inspec exec https://github.com/kraeml/lxc-rdf.git --controls lxc_net
```

### Tests auf LXC Maschinen

```bash
inspec exec https://github.com/kraeml/lxc-rdf.git --controls machines
```

## Input-File Beispiel

```yaml
---
debug: true
vagrant_hostname: vagrant
lxc_net:
  :bridge: 'lxcbr0'
  :domain: 'lxc'
  :ip: '10.0.3.1'
  :range_start: '10.0.3.2'
  :range_end: '10.0.3.254'
  :max_leases: 253
  :netmask: '255.255.255.0'
  :network: '10.0.3.0/24'
  :dnsmasq_conf: '/etc/lxc/dnsmasq.conf'
  :netzanteil: '10.0.3.'
lxc_containers:
  - :name: nodered
    :state: started
    :template: ubuntu
  - :name: mariadb
    :state: started
    :template: ubuntu
  - :name: mqtt
    :state: started
    :template: ubuntu
  - :name: postgresql
    :state: started
    :template: ubuntu
lxc_packages:
  :apts:
    - :name:
        - mosquitto
      :state: present
      :lxc_container: 'mqtt'
    - :name:
        - mariadb-server
      :state: present
      :lxc_container: 'mariadb'

  :npms:
    - :name:
        - node-red
      :state: present
      :lxc_container: 'nodered'

  :pips:
    - :name:
        - jupyter
      :state: absent
      :lxc_container: 'nodered'

lxc_ports:
  - :listening: 1880
    :protocols:
      - tcp
    :addresses:
      - 0.0.0.0
    :lxc_container: 'nodered'
lxc_services:
  - :name: 'nodered'
    :enabled: true
    :state: started
    :lxc_container: 'nodered'
...
```

Die Doppelpunkte und Einrückungen sind wichtig.

Die Doppelpunkte wird von InSpec (Ruby) als Symbole benötigt.

Die Einrückungen sind im Syntax von YAML vorgeschrieben. 

### Ausführen von machines mit Input-File

```bash
inspec exec https://github.com/kraeml/lxc-rdf.git --controls machines --input-file lxc-rdf-testing.yml
```

### Ausführen via ssh

```bash
inspec exec https://github.com/kraeml/lxc-rdf.git --controls packages ports services --input-file /vagrant/notebooks/lxc-rdf-testing.yml -t ssh://ubuntu:ubuntu@nodered.lxc
```
