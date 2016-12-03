require 'spec_helper'

describe 'neutron::db::sync' do

  shared_examples_for 'neutron-dbsync' do

    it 'runs neutron-db-sync' do
      is_expected.to contain_exec('neutron-db-sync').with(
        :command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugin.ini upgrade heads',
        :path        => '/usr/bin',
        :refreshonly => 'true',
        :try_sleep   => 5,
        :tries       => 10,
        :logoutput   => 'on_failure',
        :subscribe   => ['Anchor[neutron::install::end]',
                         'Anchor[neutron::config::end]',
                         'Anchor[neutron::dbsync::begin]'],
        :notify      => 'Anchor[neutron::dbsync::end]',
      )
    end

    describe "overriding extra_params" do
    let :params do
      {
        :extra_params => '--config-file /etc/neutron/neutron.conf',
      }
    end

    it {
        is_expected.to contain_exec('neutron-db-sync').with(
          :command     => 'neutron-db-manage --config-file /etc/neutron/neutron.conf upgrade heads',
          :path        => '/usr/bin',
          :refreshonly => 'true',
          :try_sleep   => 5,
          :tries       => 10,
          :logoutput   => 'on_failure',
          :subscribe   => ['Anchor[neutron::install::end]',
                           'Anchor[neutron::config::end]',
                           'Anchor[neutron::dbsync::begin]'],
          :notify      => 'Anchor[neutron::dbsync::end]',
        )
    }
    end

  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({
          :processorcount => 8,
          :concat_basedir => '/var/lib/puppet/concat'
        }))
      end

      it_configures 'neutron-dbsync'
    end
  end

end
