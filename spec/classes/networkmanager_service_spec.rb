# frozen_string_literal: true

require 'spec_helper'

describe 'networkmanager::service' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          service_name: 'foobar',
          enable: true,
          ensure: 'running',
          manage: true,
          restart: nil,
        }
      end

      it { is_expected.to compile }
    end
  end
end
