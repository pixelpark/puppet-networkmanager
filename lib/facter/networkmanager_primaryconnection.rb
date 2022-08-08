# frozen_string_literal: true

Facter.add(:networkmanager_primaryconnection) do
  setcode do
    nmcli = Facter.value('networkmanager_nmcli_path')
    if nmcli
      device = Facter.value('networking')['primary']
      if device
        cmd = "#{nmcli} -g general.connection d show #{device}"
        Facter::Core::Execution.execute(cmd)
      end
    end
  end
end
