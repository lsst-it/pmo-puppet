# Reboot required following the initial run
# @param war_version 
# @param pwm_version 
#  Accepts pwm_version
class profile::pwm (
  String $war_version,
  String $pwm_version,
) {
  archive { "/tmp/pwm-${war_version}.war":
    ensure   => present,
    source   => "https://github.com/pwm-project/pwm/releases/download/v${pwm_version}/pwm-${war_version}.war",
    provider => 'wget',
    cleanup  => false,
  }
  # using archive directly to destination breaks tomcat installation
  # So it must first go to the tmp folder then compied over to destination.
  $pwmconfig_dest = lookup('pwmconfig_dest')
  $pwmconfig_source = lookup('pwmconfig_source')
  file { '/opt/tomcat/webapps/ROOT.war':
    ensure => file,
    source => "/tmp/pwm-${war_version}.war",
  }
  $pwmkeystore = lookup('pwmkeystore')
  archive { '/etc/pki/keystore' :
    ensure  => present,
    source  => $pwmkeystore,
    cleanup => false,
  }
  $dc2cert = lookup('dc2cert')
  archive { '/tmp/DC2Cert.cer' :
    ensure  => present,
    source  => $dc2cert,
    cleanup => false,
  }
  $dc3cert = lookup('dc3cert')
  archive { '/tmp/DC3Cert.cer' :
    ensure  => present,
    source  => $dc3cert,
    cleanup => false,
  }
  $domaincert = lookup('domaincert')
  archive { '/tmp/lsstcertlatest.crt' :
    ensure  => present,
    source  => $domaincert,
    cleanup => false,
  }
  $domaincert2 = lookup('domaincert2')
  archive { '/tmp/lsstcertlatest.key' :
    ensure  => present,
    source  => $domaincert2,
    cleanup => false,
  }
  $chain = lookup('chain')
  archive { '/tmp/lsstcertlatestintermediate.pem' :
    ensure  => present,
    source  => $chain,
    cleanup => false,
  }
  $keystorepwd = lookup('keystorepwd')
  java_ks { 'lsst.org:/etc/pki/keystore':
    ensure              => latest,
    certificate         => '/tmp/lsstcertlatest.crt',
    private_key         => '/tmp/lsstcertlatest.key',
    chain               => '/tmp/lsstcertlatestintermediate.pem',
    password            => $keystorepwd,
    password_fail_reset => true,
  }
  file { $pwmconfig_dest:
    ensure  => file,
    source  => '/tmp/PwmConfiguration.xml',
    replace => 'no',
  }
  $applicationpath = lookup('application_path')
  $webpath = lookup('web_path')
  file { '/opt/tomcat/webapps/ROOT/WEB-INF/web.xml':
    ensure => file,
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
    ensure => file,
    source => $favicon,
  }
  archive { '/tmp/PwmConfiguration.xml' :
    ensure  => present,
    source  => $pwmconfig_source,
    cleanup => false,
  }
  # # Manage AD certs 
  java_ks { 'dc2.lsst.local:/usr/java/jdk-11.0.2+9-jre/lib/security/cacerts':
    ensure       => latest,
    certificate  => '/tmp/DC2Cert.cer',
    password     => $keystorepwd, # Must be at least 6 characters
    trustcacerts => true,
  }
  java_ks { 'dc3.lsst.local:/usr/java/jdk-11.0.2+9-jre/lib/security/cacerts':
    ensure       => latest,
    certificate  => '/tmp/DC3Cert.cer',
    password     => $keystorepwd, # Must be at least 6 characters
    trustcacerts => true,
  }
}
