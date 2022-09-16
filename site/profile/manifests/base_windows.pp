# Base profile for Windows OS
class profile::base_windows {
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
}
