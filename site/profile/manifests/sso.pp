class profile::sso ( Sensitive[String]
$pf_user_hide,
$java_home,
$pf_home,
$pf_version,
){
include 'archive'

# Ensures recursive perm change will run only initially
  unless $::pf_svc  {
    archive { '/tmp/pingfed.zip':
      source       => "http://wsus.lsst.org/puppetfiles/pingfederate/pingfederate-${pf_version}.zip",
      cleanup      => true,
      extract      => true,
      extract_path => '/opt',
    }
    # Required for Atlassian connector
    archive { '/tmp/atlassianpingfed.zip':
      source       => 'http://wsus.lsst.org/puppetfiles/pingfederate/pf-atlassian-cloud-connector-1.0.zip',
      cleanup      => true,
      extract      => true,
      extract_path => '/tmp/',
    }
    recursive_file_permissions { "/opt/pingfederate-${pf_version}/pingfederate/":
      file_mode => '0775',
      dir_mode  => '0775',
      owner     => $pf_user_hide.unwrap,
      group     => $pf_user_hide.unwrap,
    }
  }
  # Copy file needed for Atlassian connector... 
  file { "/opt/pingfederate-${pf_version}/pingfederate/server/default/deploy/pf-atlassian-cloud-quickconnection-1.0.jar":
    ensure => present,
    source => '/tmp/pf-atlassian-cloud-connector/dist/pf-atlassian-cloud-quickconnection-1.0.jar',
  }
  # ... & modify run.properties
  file { "/opt/pingfederate-${pf_version}/pingfederate/bin/run.properties":
    ensure => file,
  }
  -> file_line{ 'change pf.provisioner.mode to STANDALONE':
      match => 'pf.provisioner.mode=OFF',
      line  => 'pf.provisioner.mode=STANDALONE',
      path  => "/opt/pingfederate-${pf_version}/pingfederate/bin/run.properties",
    }
  # Log4j config for rsyslog
  $log4j = lookup('log4j')
  archive { '/tmp/log4j2.xml' :
    ensure  => present,
    source  => $log4j,
    cleanup => false,
  }
  file { "/opt/pingfederate-${pf_version}/pingfederate/server/default/conf/log4j2.xml":
    ensure  => present,
    source  => '/tmp/log4j2.xml',
    replace => 'yes',
  }
  # Download Pingfederate lic.
  archive { "/opt/pingfederate-${pf_version}/pingfederate/server/default/conf/pingfederate.lic" :
    ensure  => present,
    source  => $pf_lic,
    cleanup => false,
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
}
