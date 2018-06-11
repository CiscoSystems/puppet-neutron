require 'spec_helper'

describe 'neutron::plugins::ml2::ovn' do

  let :pre_condition do
    "class { '::neutron::keystone::authtoken':
      password => 'passw0rd',
     }
     class { 'neutron::server': }
     class { 'neutron': }"
  end

  let :default_params do
    {
       :ovn_nb_connection        => 'tcp:127.0.0.1:6641',
       :ovn_sb_connection        => 'tcp:127.0.0.1:6642',
       :ovsdb_connection_timeout => '60',
       :neutron_sync_mode        => 'log',
       :ovn_l3_mode              => true,
       :vif_type                 => 'ovs',
       :dvr_enabled              => false,
       :dns_servers              => ['8.8.8.8', '10.10.10.10'],
    }
  end

  let :test_facts do
    { :operatingsystem           => 'default',
      :operatingsystemrelease    => 'default'
    }
  end

  shared_examples_for 'neutron ovn plugin' do

    let :params do
      {}
    end

    before do
      params.merge!(default_params)
    end

    it 'should perform default configuration of' do
      is_expected.to contain_neutron_plugin_ml2('ovn/ovn_nb_connection').with_value(params[:ovn_nb_connection])
      is_expected.to contain_neutron_plugin_ml2('ovn/ovn_sb_connection').with_value(params[:ovn_sb_connection])
      is_expected.to contain_neutron_plugin_ml2('ovn/ovsdb_connection_timeout').with_value(params[:ovsdb_connection_timeout])
      is_expected.to contain_neutron_plugin_ml2('ovn/neutron_sync_mode').with_value(params[:neutron_sync_mode])
      is_expected.to contain_neutron_plugin_ml2('ovn/ovn_l3_mode').with_value(params[:ovn_l3_mode])
      is_expected.to contain_neutron_plugin_ml2('ovn/vif_type').with_value(params[:vif_type])
      is_expected.to contain_neutron_plugin_ml2('ovn/enable_distributed_floating_ip').with_value(params[:dvr_enabled])
      is_expected.to contain_neutron_plugin_ml2('ovn/dns_servers').with_value(params[:dns_servers].join(','))
    end

  end

  shared_examples_for 'Validating parameters' do
    let :params do
      {}
    end

    before :each do
      params.clear
      params.merge!(default_params)
    end

    it 'should fail with invalid neutron_sync_mode' do
      params[:neutron_sync_mode] = 'invalid'
      is_expected.to raise_error(Puppet::Error, /Invalid value for neutron_sync_mode parameter/)
    end

    it 'should fail with invalid vif_type' do
      params[:vif_type] = 'invalid'
      is_expected.to raise_error(Puppet::Error, /Invalid value for vif_type parameter/)
      params.delete(:vif_type)
      is_expected.to contain_neutron_plugin_ml2('ovn/vif_type').with_value('<SERVICE DEFAULT>')
    end

    context 'with DVR' do
      before :each do
        params.merge!(:dvr_enabled => true)
      end
      it 'should enable DVR mode' do
        is_expected.to contain_neutron_plugin_ml2('ovn/enable_distributed_floating_ip').with_value(params[:dvr_enabled])
      end
    end
  end

  on_supported_os({
    :supported_os   => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge(OSDefaults.get_facts({:processorcount => 8}))
      end

      it_configures 'neutron ovn plugin'
      it_configures 'Validating parameters'
    end
  end
end
