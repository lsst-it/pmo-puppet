# puppet master config
class profile::puppet_master {
  # The toml gem is required for grafana ldap.
  package { 'toml':
    ensure   => present,
    provider => 'puppetserver_gem',
  }
}
