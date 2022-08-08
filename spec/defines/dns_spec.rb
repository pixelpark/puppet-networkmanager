# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::dns' do
  let(:title) { 'connection0' }
  let(:params) do
    {
      nameservers: ['8.8.8.8', '8.8.4.4', '1.1.1.1'],
      searchdomains: ['example.com', 'uhu-banane.net'],
      dns_options: '',
    }
  end
  let(:pre_condition) { 'include networkmanager' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
    end
  end
end
