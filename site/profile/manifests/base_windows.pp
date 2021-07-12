# Base profile for Windows OS
class profile::base_windows {
package { 'windows_exporter':
    ensure => '0.16.0',
    source => 'https://github.com/prometheus-community/windows_exporter/releases/download/v0.16.0/windows_exporter-0.16.0-amd64.msi'
}
# Start service if it has stopped or crashed.
service { 'windows_exporter':
  ensure => running,
}
}
