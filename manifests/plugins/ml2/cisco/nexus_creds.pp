#
# Configure the Mech Driver for cisco neutron plugin
# More info available here:
# https://wiki.openstack.org/wiki/Neutron/ML2/MechCiscoNexus
#
#
# neutron::plugins::ml2::cisco::nexus_creds used by
# neutron::plugins::ml2::cisco::nexus
#

define neutron::plugins::ml2::cisco::nexus_creds(
  $username,
  $password,
  $servers,
  $ip_address,
  $ssh_port,
  $nve_src_intf = undef,
  $physnet      = undef,
) {
  # Ensure Neutron server is installed before configuring ssh keys
  if ($::neutron::params::server_package) {
    Package['neutron-server'] -> File['/var/lib/neutron/.ssh']
    Package['neutron-server'] -> Exec["nexus_creds_${name}"]
  } else {
    Package['neutron'] -> File['/var/lib/neutron/.ssh']
    Package['neutron'] -> Exec["nexus_creds_${name}"]
  }

  if ! defined(File['/var/lib/neutron/.ssh']) {
    file {'/var/lib/neutron/.ssh':
      ensure  => directory,
      owner   => 'neutron',
    }
  }

  $check_known_hosts = "/bin/cat /var/lib/neutron/.ssh/known_hosts | /bin/grep ${ip_address}"

  # Test to make sure switch is reachable before ssh-keyscan
  exec {"ping_test_${name}":
    unless  => $check_known_hosts,
    command => "/usr/bin/ping -c 1 ${ip_address}",
    user    => 'neutron'
  }

  exec {"nexus_creds_${name}":
    unless  => $check_known_hosts,
    command => "/usr/bin/ssh-keyscan -t rsa ${ip_address} >> /var/lib/neutron/.ssh/known_hosts",
    user    => 'neutron',
    require => [Exec["ping_test_${name}"], File['/var/lib/neutron/.ssh']]
  }
}
