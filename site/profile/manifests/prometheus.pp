# Prometheus monitoring URL: http://prometheus.us.lsst.org:9090/ 
class profile::prometheus (Sensitive[String]
$slackapi_hide,
$slackuser_hide,
) {
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
# Alertmanager config
class { 'prometheus::alertmanager':
  version       => '0.22.2',
  extra_options => '--cluster.listen-address=',
  route         => {
    'group_by'        => ['job'],
    'group_wait'      => '30s',
    'group_interval'  => '5m',
    'repeat_interval' => '3h',
    'receiver'        => 'slack',
  },
  receivers     => [
      {
      'name'          => 'slack',
      'slack_configs' => [
        {
          'api_url'       => unwrap($slackapi_hide),
          'channel'       => '#it_monitoring',
          'send_resolved' => true,
          'username'      => unwrap($slackuser_hide)
        },
      ],
    },
  ],
}
}
