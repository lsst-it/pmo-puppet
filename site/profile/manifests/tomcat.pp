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
}
