debug = input('debug')
# puts input_object('debug').diagnostic_string
control "lxc_net" do
  lxc_net = input('lxc_net')
  if debug
    puts input_object('lxc_net').diagnostic_string
  end
  impact 1.0
  title "LXC Netz mit dns und dhcp testen"
  desc "Das LXC Netz soll mit gegebenen Parametern laufen"
  only_if { command('hostname').stdout == "vagrant\n"}
  describe systemd_service('lxc-net') do
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  end

  describe file('/etc/default/lxc-net') do
    it { should exist }
    it { should be_file }
    it { should be_readable }
    it { should be_writable }
    it { should be_owned_by 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should match "LXC_BRIDGE=\"#{lxc_net[:'bridge']}\"" }
    its('content') { should match "LXC_ADDR=\"#{lxc_net[:'ip']}\"" }
    its('content') { should match "LXC_NETMASK=\"#{lxc_net[:'netmask']}\"" }
    its('content') { should match "LXC_NETWORK=\"#{lxc_net[:'network']}\"" }
    its('content') { should match "LXC_DHCP_RANGE=\"#{lxc_net[:'range_start']},#{lxc_net[:'range_end']}\"" }
    its('content') { should match "LXC_DHCP_MAX=\"#{lxc_net[:'max_leases']}\"" }
    its('content') { should match "#{lxc_net[:'dnsmasq_conf']}" }
    its('content') { should match "LXC_DOMAIN=\"#{lxc_net[:'domain']}\"" }
  end

  # systemd-resolve --interface=${LXC_BRIDGE} \
  #              --set-dns=${LXC_ADDR} \
  #              --set-domain=${LXC_DOMAIN:-default}
  # FAILED=0
  describe file('/usr/lib/x86_64-linux-gnu/lxc/lxc-net') do
    search = /systemd-resolve\s*.*/
    search_array = [ "--interface=.*", "--set-dns=.*", "--set-domain=.*" ]
    search_array.each do |substring|
        regex = Regexp.new( search.source + substring)
        #/
        it { should exist }
        it { should be_file }
        it { should be_readable }
        it { should be_writable }
        it { should be_owned_by 'root' }
        its('mode') { should cmp '0755' }
        its('content') { should match regex }
    end
  end

  lxc_interface=Regexp.quote("(#{lxc_net[:'bridge']})")
  white_spaces="\\n(\s*.*:\s*.*\\n\\s*)+"
  lxc_interface=lxc_interface+white_spaces
  lxc_dns_ip=Regexp.quote("DNS Servers: #{lxc_net[:'ip']}")
  lxc_dns_domain=Regexp.quote("DNS Domain: #{lxc_net[:'domain']}")
  describe bash("ps aux | grep dnsmasq ") do
    its('stdout') { should match /-s #{lxc_net[:'domain']} -S \/#{lxc_net[:'domain']}\// }
  end
  describe bash('systemd-resolve --status') do
    lxc_vagrant_dns=lxc_interface+lxc_dns_ip
    its('stdout') { should match lxc_vagrant_dns }
  end
  describe bash('systemd-resolve --status') do
    lxc_vagrant_dns=lxc_interface+lxc_dns_domain
    its('stdout') { should match lxc_vagrant_dns }
  end
end

control 'machines' do
  impact 1.0
  title 'Verfügbarkeit der LXC Maschinen'
  desc 'Erstellen der Maschine'
  desc 'ToDo Template Test einfügen'
  lxc_containers = input('lxc_containers')
  if debug
    puts input_object('lxc_containers').diagnostic_string
  end
  lxc_containers.each do |machine|
    # Run only if lxc name is set
    only_if { machine[:'name'] }
    if machine[:'state'] != 'absent'
      describe bash('sudo lxc-ls') do
        # Gefolgt von einem Whitespace
        its('stdout') { should match /#{machine[:'name']}\s+/ }
      end
      # When set stated try to start and test it.
      if machine[:'state'] == 'started'
        if bash('sudo lxc-ls --running | grep ' + machine[:'name']).exit_status != 0
          describe bash('sudo lxc-start --name ' + machine[:'name']) do
            its('exit_status') { should cmp 0 }
          end
        end
      else
        describe bash('sudo lxc-ls --running | grep ' + machine[:'name']) do
          its('exit_status') { should_not cmp 0}
        end
      end
    else
      describe bash('sudo lxc-ls') do
        # Gefolgt von einem Whitespace
        its('stdout') { should_not match /#{machine[:'name']}\s+/ }
      end
    end
  end
end

control 'packages' do
  impact 1.0
  title 'Software auf der LXC Maschinen'
  desc 'Pakete auf der Maschine'
  lxc_containers = input('lxc_packages')
  if debug
    puts input_object('lxc_packages').diagnostic_string
  end
  #lxc_containers.each do |machine|
  #  machine[:'apt'][:'name'].each do |package|
  #    describe package(package) do
  #      it { should be_installed }
  #    end
  #  end
  #end
end

control 'ports' do
  impact 1.0
  title 'Ports der LXC Maschinen'
  desc 'Ports der Maschine'
  lxc_containers = input('lxc_ports')
  if debug
    puts input_object('lxc_ports').diagnostic_string
  end
  #lxc_containers.each do |machine|
  #  machine[:'ports'].each do |port|
  #    puts port
  #    describe port(port[:'listining']) do
  #      it { should be_listening }
  #      its('protocols') {should eq port[:'protocols']}
  #      its('addresses') {should eq port[:'addresses']}
  #    end
  #  end
  #end
end

control 'services' do
  impact 1.0
  title 'Services auf der LXC Maschinen'
  desc 'Services auf der LXC Maschine'
  lxc_containers = input('lxc_services')
  if debug
    puts input_object('lxc_services').diagnostic_string
  end
  #lxc_containers.each do |machine|
  #  machine[:'services'].each do |service|
  #    describe service(service[:'name']) do
  #      it { should be_installed }
  #      it { should be_enabled }
  #      it { should be_running }
  #    end
  #  end
  #end
end

control 'users' do
  impact 1.0
  title 'Die Benutzer auf der LXC Maschinen'
  desc 'Die Benutzer auf der LXC Maschine'
  lxc_containers = input('lxc_users')
  if debug
    puts input_object('lxc_users').diagnostic_string
  end
end
