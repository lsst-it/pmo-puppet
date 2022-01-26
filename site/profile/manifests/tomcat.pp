# tomcat 
class profile::tomcat ( Sensitive[String]
$tomcat_user_hide,
$tomcat_pass_hide,
$catalina_home,
$catalina_base,
$version,
$java_home,
$https_enabled,
$keystorepass_hide,
$ciphers,
){

  tomcat::install { $catalina_home:
  source_url     => "https://dlcdn.apache.org/tomcat/${version}.tar.gz",
  }
  tomcat::instance { 'default':
    catalina_home => $catalina_home,
    catalina_base => $catalina_base,
  }
    file { '/opt/tomcat/webapps/manager/META-INF/context.xml':
    ensure => file,
    }
    -> file_line{ 'remove org.apache.catalina.valves.RemoteAddrValve':
        match => 'org.apache.catalina.valves.RemoteAddrValve',
        line  => ' ',
        path  => '/opt/tomcat/webapps/manager/META-INF/context.xml',
        }
  tomcat::config::server::tomcat_users { unwrap($tomcat_user_hide):
    password      => $tomcat_pass_hide.unwrap,
    roles         => ['admin-gui, manager-gui, manager-script'],
    catalina_base => $catalina_base,
  }
# Getting tomcat::service to work was too painful
  $tomcat_service = @("EOT")
    [Unit]
    Description=Apache Tomcat Web Application Container
    After=syslog.target network.target

    [Service]
    Type=forking
    SuccessExitStatus=143

    Environment=JAVA_HOME=${java_home}
    Environment=CATALINA_PID=${catalina_home}/temp/tomcat.pid
    Environment=CATALINA_HOME=${catalina_home}
    Environment=CATALINA_BASE=${catalina_base}
    Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
    Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

    ExecStart=${catalina_home}/bin/startup.sh
    ExecStop=${catalina_home}/bin/shutdown.sh

    User=tomcat
    Group=tomcat

    [Install]
    WantedBy=multi-user.target
    | EOT
# 
  systemd::unit_file { 'tomcat.service':
    content => "${tomcat_service}",
  }
  -> service { 'tomcat':
  subscribe => Tomcat::Instance['default'],
  ensure    => 'running',
  enable    => true,
  }
}
