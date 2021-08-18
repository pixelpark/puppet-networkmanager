require_relative '../puppet_x/pixelpark/which.rb'

Facter.add(:networkmanager_primarydevice) do
  confine kernel: 'Linux'
  setcode do
    ip = which('ip')
    if ip
      cmd = 'ip -o link | awk -F": " \'$0 ~ "^2:*" {print $2}\''
      Facter::Core::Execution.execute(cmd)
    else
      nil
    end
  end
end
