# nscliet for Windows
# Per Iain, deploying with old version (0.3.7).  
# It will be bumped up once testing is complete
# Since 0.3.7 is a very old version, the newer versions' service name is changed to ncp.
# as a result puppet run will throw an error but it should still work.
class profile::nsclient (Sensitive[String]
$nagios_password,
){
  class { 'nsclient':
    package_source_location => 'https://github.com/mickem/nscp/releases/download/0.3.7',
    package_name            => 'NSClient++ (x64)',
    package_source          => 'NSClient.-0.3.7-x64.msi',
    allowed_hosts           => ['140.252.32.34'],
    password                => unwrap($nagios_password),
    service_enable          => true,
  }
# Below service will be removed once we have upgraded to newer version of NSClient.
  service { 'NSClientpp':
  ensure => 'running',
}
}
