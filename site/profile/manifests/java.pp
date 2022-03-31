#  Base Java to be used for all Java deployments
class profile::java ( String
$version,
$jdk_version,
$version_minor,
$version_major,
$jre_version,
$distribution,
$java_home,
$java_path,
$mem,
){
  class { 'java':
    distribution => $distribution,
    version      => $version,
    java_home    => $java_home,
  }
  java::adopt { 'AdoptOpenJDK java jre 11 11.0.2 9' :
    ensure  => 'present',
    version => $jre_version,
    java    => $distribution,
  }
}
