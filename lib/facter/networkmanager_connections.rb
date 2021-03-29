
Facter.add(:networkmanager_connections) do
  setcode do
    nmcli = Facter.value('networkmanager_nmcli_path')
    if nmcli
      cmd = "#{nmcli} -g name connection show"
      Facter::Core::Execution.execute(cmd).split(%r{\n+})
    else
      nil
    end
  end
end
