# Base profile for Windows OS
class profile::base_windows (
  Boolean $graylog  = true,
) {
  include chocolatey # Needed for just about most things for Windows.
  package { 'windows_exporter':
      ensure => '0.19.0',
      source => 'https://github.com/prometheus-community/windows_exporter/releases/download/v0.19.0/windows_exporter-0.19.0-amd64.msi'
  }
  # Start service if it has stopped or crashed.
  service { 'windows_exporter':
    ensure => running,
  }
  package { 'Notepad++ (64-bit x64)':
      ensure          => installed,
      source          => 'http://wsus.lsst.org/puppetfiles/notepad/Notepad7.9.1.msi',
      install_options => '/quiet',
  }
  if $graylog {
    package { 'NXLog-CE':
        ensure => '2.10.2150',
        source => 'https://project.lsst.org/zpuppet/nxlog/nxlog-ce-2.10.2150.msi'
    }
    file { 'C:/Program Files (x86)/nxlog/conf/nxlog.conf':
        ensure => 'present',
        source => 'https://project.lsst.org/zpuppet/nxlog/nxlog.conf'
    }
    service { 'nxlog':
        ensure => 'running',
        enable => true
    }
  }
}
