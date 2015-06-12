#
# Configure the Mech Driver for Cisco UCSM plugin
# More info available here:
# http://docwiki.cisco.com/wiki/UCS_Mechanism_Driver_for_ML2_Plugin:_Kilo
#
# === Parameters
#
# [*ucsm_ip*]
#   IP address of the Cisco UCS Manager
#
# [*ucsm_username*]
#   Username to connect to the UCS Manager
#
# [*ucsm_password*]
#   Password to connect to the UCS Manager
#
# [*ucsm_host_list*]
#   Hostname to Service profile mapping for UCSM-controlled compute hosts
#   Example:
#   Hostname1:Serviceprofile1, Hostname2:Serviceprofile2
#
# [*supported_pci_devs*]
#   (optional) SR-IOV and VM-FEX vendors supported by this plugin
#   xxxx:yyyy represents vendor_id:product_id
#   Defaults to undef
#   Example:
#   [ '2222:3333', '4444:5555' ]
#

class neutron::plugins::ml2::cisco::ucsm (
  $ucsm_ip,
  $ucsm_username,
  $ucsm_password,
  $ucsm_host_list,
  $supported_pci_devs = undef,
) {
  include neutron::plugins::ml2::cisco::cisco_ml2

  concat::fragment { 'ucsm_config':
    target  => $::neutron::params::cisco_ml2_config_file,
    content => template('neutron/ml2_conf_cisco_ucsm.erb')
  }
}

