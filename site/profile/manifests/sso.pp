class profile::sso ( Sensitive[String]
$pf_user,
$java_home,
$pf_home,
$pf_version,
){
include 'archive'

  archive { '/tmp/pingfed.zip':
    source       => 'https://project.lsst.org/zpuppet/pingfederate/pingfederate-11.0.2.zip',
    cleanup      => true,
    extract      => true,
    extract_path => '/opt',
  }
  $pingfederate_service = @("EOT")
    [Unit]
    Description=PingFederate ${pf_version}
    Documentation=https://support.pingidentity.com/s/PingFederate-help

    [Install]
    WantedBy=multi-user.target

    [Service]
    Type=simple
    User=${pf_user}
    WorkingDirectory=${pf_home}
    Environment='JAVA_HOME=${java_home}'
    ExecStart=${pf_home}/bin/run.sh

    | EOT
# 
  systemd::unit_file { 'pingfederate.service':
    content => "${pingfederate_service}",
    mode => '0664',
  }
  -> service { 'pingfederate':
      ensure    => 'running',
      enable    => true,
    }
  recursive_file_permissions { '/opt/pingfederate-11.0.2/pingfederate/':
    file_mode => '0775',
    dir_mode  => '0775',
    owner     => $pf_user,
    group     => $pf_user,
  }
}
