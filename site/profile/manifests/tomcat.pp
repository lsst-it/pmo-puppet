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

}
