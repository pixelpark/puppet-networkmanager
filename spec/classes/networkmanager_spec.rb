# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager' do
  let(:params) do
    {
      global_nameservers: ['8.8.8.8', '8.8.4.4', '1.1.1.1'],
      global_searchdomains: ['example.com', 'uhu-banane.net'],
      global_dns_options: '',
      nameservers: ['8.8.8.8', '8.8.4.4', '1.1.1.1'],
      dns_searchdomains: ['example.com', 'uhu-banane.net'],
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os} without manage_dns" do
      let(:facts) { os_facts }
      let(:params) do
        super().merge(manage_dns: false)
      end

      it { is_expected.to compile }
    end

    context "on #{os} with manage_dns" do
      let(:facts) { os_facts }
      let(:params) do
        super().merge(
          manage_dns: true,
          dns_options: ['timeout:3', 'attempts:3', 'use-vc'],
          dns_notify_daemon: false,
        )
      end

      it { is_expected.to compile }
    end
  end
end
