# Base profile for Linux OS
class profile::base_linux {
  include network
  include ::firewalld
# config: /etc/systemd/system/node_exporter.service
  class { 'prometheus::node_exporter':
    version       => '1.1.2',
    extra_options => '--collector.systemd \--collector.processes \--collector.meminfo_numa',
  }
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
