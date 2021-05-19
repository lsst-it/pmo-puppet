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
  }
  }

  firewalld_port { 'Grafana Main Port':
    ensure   => present,
    port     => '3000',
    protocol => 'tcp',
    require  => Service['firewalld'],
  }
}
