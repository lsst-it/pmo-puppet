# puppet master config
class profile::puppet_master {
  include r10k
  # The toml gem is required for grafana ldap.
  package { 'toml':
    ensure   => present,
    provider => 'puppetserver_gem',
  }
  package { 'hiera-eyaml':
    ensure   => '3.4.0',
    provider => 'puppetserver_gem',
  }
}
