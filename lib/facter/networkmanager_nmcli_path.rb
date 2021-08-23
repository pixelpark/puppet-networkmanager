require_relative '../puppet_x/pixelpark/which.rb'

Facter.add(:networkmanager_nmcli_path) do
  setcode do
    which('nmcli')
  end
end
