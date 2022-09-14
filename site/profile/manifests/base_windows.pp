# Base profile for Windows OS
class profile::base_windows {
  include chocolatey # Needed for just about most things for Windows.
  package { 'windows_exporter':
      ensure => '0.19.0',
      source => 'https://github.com/prometheus-community/windows_exporter/releases/download/v0.19.0/windows_exporter-0.19.0-amd64.msi'
  }
  package { 'Notepad++ (64-bit x64)':
      ensure => '8.4.5',
      source => 'https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4.5/npp.8.4.5.Installer.x64.exe'
  }  # Start service if it has stopped or crashed.
  service { 'windows_exporter':
    ensure => running,
  }
}
