# Prometheus monitoring URL: http://prometheus.us.lsst.org:9090/ 
class profile::prometheus (Sensitive[String]
$slackapi_hide,
$slackuser_hide,
$cluster_hide,
$advertise_ip,
) {
# Firewall rules are in private repo
  include prometheus
  include prometheus::snmp_exporter
  file { '/etc/alertmanager/notifications.tmpl':
    ensure  => file,
    content => epp('profile/alertmanager_custom.epp'),
  }
  class { 'prometheus::blackbox_exporter':
    version => '0.23.0',
    modules => {
      'http_2xx'    => {
        'prober'  => 'http',
        'timeout' => '5s',
        'http'    => {
          'valid_status_codes'    => [],
          'method'                => 'GET',
          'preferred_ip_protocol' => 'ip4',
        }
      },
      'tcp_connect' => {
        'prober' => 'tcp',
      },
      'icmp'        => {
        'prober' => 'icmp',
      },
    }
  }
# Alertmanager config
class { 'prometheus::alertmanager':
  version       => '0.25.0',
  extra_options => "--cluster.advertise-address=${advertise_ip} \--cluster.listen-address=:9797 \--cluster.peer=${unwrap($cluster_hide)}",
  route         => {
    'group_by'        => ['job'],
    'group_wait'      => '30s', # how long to wait to buffer alerts of the same group before sending a notification initially
    'group_interval'  => '45s',  # ^^before sending an alert that has been added to a group for which there has already been a notification
    'repeat_interval' => '3h',  # how long to wait before re-sending a given alert that has already been sent in a notification
    'receiver'        => 'slack',
  },
  receivers     => [
      {
      'name'          => 'slack',
      'slack_configs' => [
        {
          'api_url'       => unwrap($slackapi_hide),
          'channel'       => '#it_monitoring',
          'icon_url'      => 'https://avatars3.githubusercontent.com/u/3380462',
          'title'         => '{{ template "custom_title" . }}',
          'text'          => '{{ template "custom_slack_message" . }}',
          'send_resolved' => true,
          'username'      => unwrap($slackuser_hide),
        },
      ],
    },
  ],
}
}
