# frozen_string_literal: true

require_relative '../puppet_x/pixelpark/nm_which'

Facter.add(:networkmanager_nmcli_path) do
  setcode do
    which('nmcli')
  end
end
