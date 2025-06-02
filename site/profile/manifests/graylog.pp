# Graylog configuration
class profile::graylog {
  $fqdn = $facts['networking']['fqdn']
  $pass_secret = lookup('pass_secret')
  $root_password_sha2 = lookup('root_password_sha2')
  $glog_pwd = lookup('glog_pwd')
  $ssldir = lookup('ssldir')
  include java_ks::config

  class { 'elastic_stack::repo':
    version => 7,
    oss     => true,
  }
  class { 'elasticsearch':
    version           => '7.10.2', #Currently 7.11 and above not supported in Graylog
    oss               => true,
    manage_repo       => true,
    restart_on_change => true,
    config            => {
      'cluster.name' => 'graylog',
      'network.host' => '127.0.0.1',
    },
    jvm_options       => [
      '-Xms4g',
      '-Xmx4g',
    ],
  }
  class { 'mongodb::globals':
    manage_package_repo => true,
    version             => '6.0.15',
  }
  ->class { 'mongodb::server':
    bind_ip       => ['127.0.0.1'],
    set_parameter => ['diagnosticDataCollectionEnabled: false'], # Makes SELinux happy
  }
  # Directory and files for TLS
  $tlskey = lookup('tlskey')
  $tlscert = lookup('tlscert')
  $tlschain = lookup('tlschain')
  file {
    $ssldir:
      ensure => directory,
      mode   => '0700',
      owner  => 'graylog',
      group  => 'graylog',
      ;
    "${ssldir}/graylog.key":
      ensure  => file,
      content => $tlskey.unwrap,
      ;
    "${ssldir}/graylog.crt":
      ensure  => file,
      content => $tlscert.unwrap,
      ;
    "${ssldir}/graylog.pem":
      ensure  => file,
      content => $tlschain.unwrap,
      ;
    "${ssldir}/cacerts.jks":
      ensure  => file,
      source  => '/usr/share/graylog-server/jvm/lib/security/cacerts',
      replace => false,
  }
  # java_ks cannot find keytool, so this symlink is needed
  file { '/usr/local/bin/keytool':
    ensure => link,
    target => '/usr/share/graylog-server/jvm/bin/keytool',
  }
  java_ks { "lsst.org:${ssldir}//cacerts.jks":
    ensure              => latest,
    certificate         => "${ssldir}/graylog.crt",
    private_key         => "${ssldir}/graylog.key",
    chain               => "${ssldir}/graylog.pem",
    password            => 'changeit',
    password_fail_reset => true,
  }
  class { 'graylog::repository':
    version => '6.2',
  }
  ->class { 'graylog::server':
    package_version => '6.2.2',
    config          => {
      is_leader                           => true,
      node_id_file                        => '/etc/graylog/server/node-id',
      password_secret                     => $pass_secret.unwrap,
      root_username                       => 'admin',
      root_password_sha2                  => $root_password_sha2.unwrap,
      root_timezone                       => 'UTC',
      allow_leading_wildcard_searches     => false,
      allow_highlighting                  => false,
      http_bind_address                   => '0.0.0.0:443',
      http_external_uri                   => "https://${fqdn}/",
      http_publish_uri                    => "https://${fqdn}/",
      http_enable_tls                     => true,
      http_tls_cert_file                  => "${ssldir}/graylog.crt",
      http_tls_key_file                   => "${ssldir}/graylog.key",
      rotation_strategy                   => 'time',
      retention_strategy                  => 'delete',
      elasticsearch_max_time_per_index    => '7d',
      elasticsearch_max_number_of_indices => '30',
      elasticsearch_shards                => '4',
      elasticsearch_replicas              => '1',
      elasticsearch_index_prefix          => 'graylog',
      elasticsearch_hosts                 => 'http://127.0.0.1:9200',
      mongodb_uri                         => 'mongodb://127.0.0.1:27017/graylog',
    },
    java_opts       => "-Xms2g -Xmx2g -XX:NewRatio=1 -server -XX:+ResizeTLAB -XX:-OmitStackTraceInFastThrow -Djavax.net.ssl.trustStore=${ssldir}/cacerts.jks",
  }
}
