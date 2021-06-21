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
        isDefault => true,
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
