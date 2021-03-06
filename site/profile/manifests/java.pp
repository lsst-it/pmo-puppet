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
  java::adopt { $distribution :
    ensure        => 'present',
    version       => $jre_version,
    version_major => $version_major, # If not specified, it will keep reinstalling.
    version_minor => $version_minor, # ditto.
    java          => $distribution,
  }
}
