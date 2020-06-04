require 'spec_helper'

RSpec.describe 'fluentd' do
  test_on = {
    hardwaremodels: ['x86_64'],
    supported_os: [
      {
        'operatingsystem'        => 'CentOS',
        'operatingsystemrelease' => ['6', '7'],
      },
      {
        'operatingsystem'        => 'Ubuntu',
        'operatingsystemrelease' => ['16', '18'],
      },
    ],
  }

  on_supported_os(test_on).each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'base' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('fluentd') }
        it { is_expected.to contain_class('fluentd::install') }
        it { is_expected.to contain_class('fluentd::service') }
      end

      context 'with plugins' do
        let(:params) { { plugins: { plugin_name => plugin_params } } }
        let(:plugin_name) { 'fluent-plugin-http' }
        let(:plugin_params) { { 'plugin_ensure' => '0.1.0' } }

        it { is_expected.to contain_fluentd__plugin(plugin_name).with(plugin_params) }
      end

      context 'with configs' do
        let(:params) { { configs: { config_name => config_params } } }
        let(:config_name) { '100_fwd.conf' }
        let(:config_params) { { 'config' => { 'source' => { 'type' => 'forward' } } } }

        it { is_expected.to contain_fluentd__config(config_name).with(config_params) }
      end
    end
  end
end
