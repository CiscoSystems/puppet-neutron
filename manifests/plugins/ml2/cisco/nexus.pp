#
# Configure the Mech Driver for cisco neutron plugin
# More info available here:
# https://wiki.openstack.org/wiki/Neutron/ML2/MechCiscoNexus
#
# === Parameters
#
# [*nexus_config*]
# Nexus switch configuration for ml2_cisco_conf.ini
# Example nexus config format:
#  { 'switch_hostname' => {'username' => 'admin',
#    'ssh_port' => 22,
#    'password' => "password",
#    'ip_address' => "172.18.117.28",
#    'nve_src_intf' => 1,
#    'physnet' => "physnet1",
#    'servers' => {
#      'control01' => "portchannel:20",
#      'control02' => "portchannel:10"
#    }}}
#
# [*managed_physical_network*]
#   The name of the physical_network managed via the Cisco Nexus Switch.
#   This string value must be present in the ml2_conf.ini network_vlan_ranges
#   variable.
#
# [*vlan_name_prefix*]
#   (optional) A short prefix to prepend to the VLAN number when creating a
#   VLAN interface. For example, if an interface is being created for
#   VLAN 2001 it will be named 'q-2001' using the default prefix.
#   The total length allowed for the prefix name and VLAN is 32 characters,
#   the prefix will be truncated if the total length is greater than 32.
#   Defaults to 'q-'
#
# [*svi_round_robin*]
#   (optional) A flag to enable round robin scheduling of routers for SVI.
#   Defaults to False
#
# [*provider_vlan_name_prefix*]
#   (optional) A short prefix to prepend to the VLAN number when creating a
#   provider VLAN interface. For example, if an interface is being created
#   for provider VLAN 3003 it will be named 'p-3003' using the default prefix.
#   The total length allowed for the prefix name and VLAN is 32 characters,
#   the prefix will be truncated if the total length is greater than 32.
#   Defaults to 'p-'
#
# [*persistent_switch_config*]
#   (optional) To make Nexus device persistent by running the Nexus
#   CLI 'copy run start' after applying successful configurations.
#   (default) This flag defaults to False keep consistent with
#   existing functionality.
#   Defaults to False
#
# [*switch_heartbeat_time*]
#   (optional) Time interval to check the state of the Nexus device.
#   (default) This value defaults to 0 seconds which disables this
#   functionality.  When enabled, 30 seconds is suggested.
#   Defaults to 0
#
# [*switch_replay_count*]
#   (optional) Number of times to attempt config replay with switch.
#   This variable depends on switch_heartbeat_time being enabled.
#   Defaults to 3
#
# [*provider_vlan_auto_create*]
#   (optional) A flag indicating whether OpenStack networking should manage the
#   creation and removal of VLANs for provider networks on the Nexus
#   switches. If the flag is set to False then OpenStack will not create or
#   remove VLANs for provider networks, and the administrator needs to
#   manage these interfaces manually or by external orchestration.
#   Defaults to True
#
# [*provider_vlan_auto_trunk*]
#   (optional) A flag indicating whether OpenStack networking should manage
#   the adding and removing of provider VLANs from trunk ports on the Nexus
#   switches. If the flag is set to False then OpenStack will not add or
#   remove provider VLANs from trunk ports, and the administrator needs to
#   manage these operations manually or by external orchestration.
#   Defaults to True
#
# [*vxlan_global_config*]
#   (optional) A flag indicating whether OpenStack networking should manage the
#   creating and removing of the Nexus switch VXLAN global settings of 'feature
#   nv overlay', 'feature vn-segment-vlan-based', 'interface nve 1' and the NVE
#   subcommand 'source-interface loopback #'. If the flag is set to False
#   (default) then OpenStack will not add or remove these VXLAN settings, and
#   the administrator needs to manage these operations manually or by  external
#   orchestration.
#   Defaults to True
#
# [*host_key_checks*]
#   (optional) A flag indicating whether or not to enable strict host key checks
#   when connecting to Nexus switches.
#   Defaults to False
#

class neutron::plugins::ml2::cisco::nexus (
  $nexus_config,
  $managed_physical_network,
  $vlan_name_prefix          = 'q-',
  $svi_round_robin           = False,
  $provider_vlan_name_prefix = 'p-',
  $persistent_switch_config  = False,
  $switch_heartbeat_time     = 0,
  $switch_replay_count       = 3,
  $provider_vlan_auto_create = True,
  $provider_vlan_auto_trunk  = True,
  $vxlan_global_config       = True,
  $host_key_checks           = False
) {
  include neutron::plugins::ml2::cisco::cisco_ml2

  concat::fragment { 'nexus_config':
    target  => $::neutron::params::cisco_ml2_config_file,
    content => template('neutron/ml2_conf_cisco_nexus.erb')
  }

  create_resources(neutron::plugins::ml2::cisco::nexus_creds, $nexus_config)

}

