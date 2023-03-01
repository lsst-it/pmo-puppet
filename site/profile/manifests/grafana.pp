# Grafana url: http://grafana-x.lsst.org:3000
class profile::grafana ( String
$pname1,
$url1,
$pname2,
$url2,
) {
  $grafana_pwd = lookup('grafana_pwd')
  class { 'grafana':
    version                  => '9.3.6',
    provisioning_datasources => {
    apiVersion  => 1,
    datasources => [
      {
        name      => $pname1,
        type      => 'prometheus',
        access    => 'proxy',
        url       => $url1,
        isDefault => true,
      },
      {
        name      => $pname2,
        type      => 'prometheus',
        access    => 'proxy',
        url       => $url2,
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
      security    => {
        admin_user     => 'admin',
        admin_password => $grafana_pwd,
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
