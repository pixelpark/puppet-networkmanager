Facter.add(:networkmanager_dns) do
  setcode do
    connections = Facter.value(:networkmanager_connections)

    if connections
      dns = {}
      nmcli = Facter.value(:networkmanager_nmcli_path)
      connections.each do |connection|
        dns[connection] = {}
        dns[connection][:nameserver] = Facter::Core::Execution.execute("#{nmcli} -g ipv4.dns connection show id #{connection}").split(',')
        dns[connection][:search] = Facter::Core::Execution.execute("#{nmcli} -g ipv4.dns-search connection show id #{connection}").split(',')
        dns[connection][:options] = Facter::Core::Execution.execute("#{nmcli} -e no -g ipv4.dns-options connection show id #{connection}").split(',')
      end
    end

    if connections
      dns
    else
      nil
    end
  end
end
