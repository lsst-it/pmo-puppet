# Prometheus monitoring URL: http://prometheus.us.lsst.org:9090/ 
class profile::prometheus (Sensitive[String]
$account_hide,
$account_token,
$to_hide,
){
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
  version   => '0.22.2',
  # route     => {
  #   'group_by'        => ['job'],
  #   'group_wait'      => '30s',
  #   'group_interval'  => '5m',
  #   'repeat_interval' => '3h',
  #   'receiver'        => 'email',
  # },
  # receivers => [
  #   {
  #     'name'          => 'email',
  #     'email_configs' => [
  #       {
  #         'to'            => unwrap($to_hide),
  #         'from'          => unwrap($account_hide),
  #         'smarthost'     => 'smtp.gmail.com:587',
  #         'auth_username' => unwrap($account_hide),
  #         'auth_identity' => unwrap($account_hide),
  #         'auth_password' => unwrap($account_token),
  #         'require_tls'   => true,
  #         'send_resolved' => true,
  #       },
  #     ],
  #   },
  # ],
}
}
