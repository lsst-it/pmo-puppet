# puppet master config
class profile::puppet_master {
  include r10k
  # The toml gem is required for grafana ldap.
  package { 'toml':
    ensure   => present,
    provider => 'puppetserver_gem',
  }
  # $prkpem = lookup('prkpem')
  # $pukpem = lookup('pukpem')
  # file {
  #   '/etc/puppetlabs/puppet/eyaml':
  #     ensure => directory,
  #     owner  => 'puppet',
  #     group  => 'puppet',
  #     mode   => '0500',
  #     ;
  #   '/etc/puppetlabs/puppet/eyaml/private_key.pkcs7.pem':
  #     ensure  => file,
  #     owner   => 'puppet',
  #     group   => 'puppet',
  #     mode    => '0400',
  #     content => $prkpem,
  #     ;
  #   '/etc/puppetlabs/puppet/eyaml/public_key.pkcs7.pem':
  #     ensure  => file,
  #     owner   => 'puppet',
  #     group   => 'puppet',
  #     mode    => '0400',
  #     content => $pukpem,
  #     ;
  # }
}
