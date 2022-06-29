class profile::sso ( Sensitive[String]
$pf_user_hide,
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
  # Required for Atlassian connector
    archive { '/tmp/atlassianpingfed.zip':
    source       => 'https://project.lsst.org/zpuppet/pingfederate/pf-atlassian-cloud-connector-1.0.zip',
    cleanup      => true,
    extract      => true,
    extract_path => '/tmp/',
  }
  # Copy file needed for Atlassian connector... 
  file { '/opt/pingfederate-11.0.2/pingfederate/server/default/deploy/pf-atlassian-cloud-quickconnection-1.0.jar':
    ensure => present,
    source => '/tmp/pf-atlassian-cloud-connector/dist/pf-atlassian-cloud-quickconnection-1.0.jar',
  }
  # ... & modify run.properties
  file { '/opt/pingfederate-11.0.2/pingfederate/bin/run.properties':
    ensure => file,
  }
  -> file_line{ 'change pf.provisioner.mode to STANDALONE':
      match => 'pf.provisioner.mode=OFF',
      line  => 'pf.provisioner.mode=STANDALONE',
      path  => '/opt/pingfederate-11.0.2/pingfederate/bin/run.properties',
    }
  # Pingfederate service

  $pingfederate_service = @("EOT")
    [Unit]
    Description=PingFederate ${pf_version}
    Documentation=https://support.pingidentity.com/s/PingFederate-help

    [Install]
    WantedBy=multi-user.target

    [Service]
    Type=simple
    User=${pf_user_hide.unwrap}
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
    owner     => $pf_user_hide.unwrap,
    group     => $pf_user_hide.unwrap,
  }
}
