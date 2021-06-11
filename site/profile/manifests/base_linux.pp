# Base profile for Linux OS
class profile::base_linux {
  include network
  include prometheus::node_exporter
class { 'timezone':
    timezone => 'UTC',
}
Package { [ 'tree', 'tcpdump', 'telnet', 'lvm2', 'gcc', 'xinetd',
'bash-completion', 'sudo', 'screen', 'vim', 'openssl', 'openssl-devel',
'wget', 'nmap', 'iputils', 'bind-utils']:
ensure => installed,
}
}
