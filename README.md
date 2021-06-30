# LXC RDF InSpec Profile

Hier wird der LXC-Stack der Rudolf Diesel Fachschule getestet.

## Durchführen

### Alle Tests

inspec exec https://github.com/kraeml/lxc-rdf.git

ACHTUNG: Es wird nur der localhost (Vagrant) überprüft. Zur Zeit lxc_net und machines.

### LXC Netzwerk

inspec exec https://github.com/kraeml/lxc-rdf.git --controls lxc_net

### Tests auf LXC Maschinen

inspec exec https://github.com/kraeml/lxc-rdf.git --controls machines
