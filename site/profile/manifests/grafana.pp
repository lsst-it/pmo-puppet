# Grafana url: http://grafana-x.lsst.org:3000
class profile::grafana {

  class { 'grafana':
    version                  => '9.3.6',
    provisioning_datasources => {
    apiVersion  => 1,
    datasources => [
      {
        name      => 'mr-tuc-1',
        type      => 'prometheus',
        access    => 'proxy',
        url       => 'http://mr-tuc-1.lsst.org:9090/',
        isDefault => true,
      },
      {
        name      => 'mr-tuc-2',
        type      => 'prometheus',
        access    => 'proxy',
        url       => 'http://mr-tuc-2.lsst.org:9090/',
        isDefault => false,
      },
    ],
    },
    cfg                      => {
      'auth.ldap' => {
        enabled     => true,
        config_file => '/etc/grafana/ldap.toml',
      },
      server      => {
        http_port => 3000,
        cert_key  => '/etc/grafana/grafana.key',
        cert_file => '/etc/grafana/grafana.crt',
        protocol  => 'https',
      },
    }
  }
  $domaincert = lookup('domaincert')
  archive { '/etc/grafana/grafana.crt' :
    ensure  => present,
    source  => $domaincert,
    cleanup => false,
  }
  $domaincert2 = lookup('domaincert2')
  archive { '/etc/grafana/grafana.key' :
    ensure  => present,
    source  => $domaincert2,
    cleanup => false,
  }
}
