# Base profile for Windows OS
# @param graylog
#  If `false`, graylog will not be configured
class profile::base_windows (
  Boolean $graylog  = true,
) {
  include chocolatey # Needed for just about most things for Windows.
  package { 'windows_exporter':
    ensure => '0.19.0',
    source => 'https://github.com/prometheus-community/windows_exporter/releases/download/v0.19.0/windows_exporter-0.19.0-amd64.msi',
  }
  # Start service if it has stopped or crashed.
  service { 'windows_exporter':
    ensure => running,
  }
# Graylog config
  if $graylog {
    package { 'NXLog-CE':
      ensure => '2.10.2150',
      source => 'http://wsus.lsst.org/puppetfiles/nxlog/nxlog-ce-2.10.2150.msi',
    }
    file { 'C:/Program Files (x86)/nxlog/conf/nxlog.conf':
      ensure => file,
      source => 'http://wsus.lsst.org/puppetfiles/nxlog/nxlog.txt',
    }
  }
}
