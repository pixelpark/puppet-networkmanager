
Facter.add(:networkmanager_primaryconnection) do
  setcode do
    nmcli = Facter.value('networkmanager_nmcli_path')
    if nmcli
      device = Facter.value('networkmanager_primarydevice')
      if device
        cmd = "#{nmcli} -g general.connection d show #{device}"
        Facter::Core::Execution.execute(cmd)
      else
        nil
      end
    else
      nil
    end
  end
end
