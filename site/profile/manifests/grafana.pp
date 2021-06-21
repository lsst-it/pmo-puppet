# Grafana url: http://grafana.us.lsst.org:3000
class profile::grafana {

  class { 'grafana':
    version                  => '7.5.3',
    provisioning_datasources => {
    apiVersion  => 1,
    datasources => [
      {
        name      => 'Prometheus',
        type      => 'prometheus',
        access    => 'proxy',
        url       => 'http://prometheus.us.lsst.org:9090/',
        isDefault => false,
      },
      {
        name      => 'mr-tuc-1',
        type      => 'prometheus',
        access    => 'proxy',
        url       => 'http://mr-tuc-1.us.lsst.org:9090/',
        isDefault => true,
      },
      {
        name      => 'mr-tuc-2',
        type      => 'prometheus',
        access    => 'proxy',
        url       => 'http://mr-tuc-2.us.lsst.org:9090/',
        isDefault => false,
      },
    ],
  },
    cfg                      => {
    'auth.ldap' => {
      enabled     => true,
      config_file => '/etc/grafana/ldap.toml',
    },
  }
}
}
