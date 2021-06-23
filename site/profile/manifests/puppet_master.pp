# puppet master config
class profile::puppet_master {
  # The toml-rb gem is required for grafana ldap.
  package { 'toml-rb':
    provider => 'puppetserver_gem',
    notify   => Service['puppetserver'],
  }
  }
