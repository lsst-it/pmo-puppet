# NX Log Agent
# Requires Source MSI
# Requires Source Conf file
# Verify installed
# Verify conf file exists and proper content
# Verify service exists and is running
class profile::monitoring_graylog {
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
# TO Do Need to restrict alnitak zpuppet directory to limited set of ip addresses