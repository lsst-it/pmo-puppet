# Base profile for Linux OS
class profile::base_linux {
  include network
  include firewalld
  include prometheus::node_exporter
class { 'ntp':
  servers => [ '140.252.1.140', '140.252.1.141' ],
}
class { 'timezone':
    timezone => 'UTC',
}
Package { [ 'tree', 'tcpdump', 'telnet', 'lvm2', 'gcc', 'xinetd',
'bash-completion', 'sudo', 'screen', 'vim', 'openssl', 'openssl-devel',
'wget', 'nmap', 'iputils', 'bind-utils']:
ensure => installed,
}
}
