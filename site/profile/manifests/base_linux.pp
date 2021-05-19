# Base profile for Linux OS
class profile::base_linux {
    include node_exporter
Package { [ 'tree', 'tcpdump', 'telnet', 'lvm2', 'gcc', 'xinetd',
'bash-completion', 'sudo', 'screen', 'vim', 'openssl', 'openssl-devel',
'wget', 'nmap']:
ensure => installed,
}
}
