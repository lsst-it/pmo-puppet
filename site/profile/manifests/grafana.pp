# Grafana url: http://grafana-x.lsst.org:3000
# @param pname1
#  Prometheus Server name 'mr-tuc-1.lsst.org'
# @param pname2
#  Prometheus 2nd Server name 'mr-tuc-2.lsst.org'
# @param url1
#  Prometheus URL 'http://mr-tuc-1.lsst.org:9090'
# @param url2
#  Prometheus URL 'http://mr-tuc-2.lsst.org:9090'
class profile::grafana (
  String $pname1,
  String $url1,
  String $pname2,
  String $url2,
) {
  $grafana_pwd = lookup('grafana_pwd')
  class { 'grafana':
    version                  => '11.2.0',
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
    },
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
