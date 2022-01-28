# Reboot required following the initial run
class profile::pwm {

  archive { '/tmp/pwm-1.9.2.war':
    ensure   => present,
    source   => 'https://github.com/pwm-project/pwm/releases/download/v1_9_2/pwm-1.9.2.war',
    provider => 'wget',
    cleanup  => false,
  }
  # using archive directly to destination breaks tomcat installation
  # So it must first go to the tmp folder then compied over to destination.
  $pwmconfig_dest = lookup('pwmconfig_dest')
  $pwmconfig_source = lookup('pwmconfig_source')
  archive { '/tmp/PwmConfiguration.xml' :
    ensure  => present,
    source  => $pwmconfig_source,
    cleanup => false,
  }
  file { '/opt/tomcat/webapps/pwm.war':
    ensure => present,
    source => '/tmp/pwm-1.9.2.war',
  }
  $pwmkeystore = lookup('pwmkeystore')
  archive { '/etc/pki/keystore' :
    ensure  => present,
    source  => $pwmkeystore,
    cleanup => false,
  }
}
