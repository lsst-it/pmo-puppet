#  Base Java to be used for all Java deployments
# @param version
#  Java Version
# @param jdk_version
#  jdk version
# @param version_minor
#  Java version minor
# @param version_major
#  Java version major
# @param jre_version
#  JRE version
# @param distribution
#  Java distributin
# @param java_home
#  Java HOME location
# @param java_path
#  Java path
# @param mem
#  Java memory allocation
class profile::java (
  String $version,
  String $jdk_version,
  String $version_minor,
  String $version_major,
  String $jre_version,
  String $distribution,
  String $java_home,
  String $java_path,
  String $mem,
) {
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
