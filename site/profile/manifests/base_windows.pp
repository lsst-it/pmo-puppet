# Base profile for Windows OS
# @param graylog
#  If `false`, graylog will not be configured
class profile::base_windows (
  Boolean $graylog  = true,
) {
  include chocolatey # Needed for just about most things for Windows.
  package { 'windows_exporter':
    ensure => '0.26.2',
    source => 'https://github.com/prometheus-community/windows_exporter/releases/download/v0.26.2/windows_exporter-0.26.2-amd64.msi',
  }
  # Start service if it has stopped or crashed.
  service { 'windows_exporter':
    ensure => running,
  }
# Graylog config
  if $graylog {
    package { 'NXLog-CE':
      ensure => '3.2.2329',
      source => 'http://wsus.lsst.org/puppetfiles/nxlog/nxlog-ce-3.2.2329.msi',
    }
    file { 'C:/Program Files/nxlog/conf/nxlog.conf':
      ensure => file,
      source => 'http://wsus.lsst.org/puppetfiles/nxlog/nxlog3.2.2329.conf',
      notify => Service['nxlog'],
    }
    file { 'C:/Program Files (x86)/nxlog': # removes the old orphaned folder
      ensure => absent,
      force  => true,
    }
    service { 'nxlog':
      ensure => 'running',
      enable => true,
    }
  }
}
