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
  file { $pwmconfig_dest:
    ensure => present,
    source => '/tmp/PwmConfiguration.xml',
  }
$applicationpath = lookup('application_path')
  $webpath = lookup('web_path')
  file { '/opt/tomcat/webapps/ROOT/WEB-INF/web.xml':
    ensure => present,
  }
  -> file_line { 'Append line to ROOT/WEB-INF/web.xml':
      path  => $webpath,
      line  => "<param-value>${applicationpath}</param-value>",
      match => '<param-value>unspecified</param-value>',
    }
    $lsst_theme = lookup('lsst_theme')
    file {
      '/opt/tomcat/webapps/ROOT/public/resources/themes/lsst':
        ensure => directory,
    }
    archive { '/tmp/lsst.zip' :
      source       => $lsst_theme,
      cleanup      => false,
      extract      => true,
      extract_path => '/opt/tomcat/webapps/ROOT/public/resources/themes/lsst',
    }
  $favicon = lookup('favicon')
  file { '/opt/tomcat/webapps/ROOT/public/resources/favicon.png':
    ensure => present,
    source => $favicon,
  }
}
