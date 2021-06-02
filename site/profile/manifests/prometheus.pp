# Prometheus monitoring URL: http://prometheus.us.lsst.org:9090/ 
class profile::prometheus {
  include prometheus
  class { 'prometheus::blackbox_exporter':
    version => '0.19.0',
    modules => {
      'http_2xx' => {
        'prober'  => 'http',
        'timeout' => '5s',
        'http'    => {
          'valid_status_codes' => [],
          'method'             => 'GET',
        }
      }
    }
  }
}
