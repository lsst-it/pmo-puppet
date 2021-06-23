# puppet master config
class profile::puppet_master {
  # The toml-rb gem is required for grafana ldap.
  package { 'toml-rb':
    notify   => Service['puppetserver'],
    provider => 'puppetserver_gem',
  }
  }
