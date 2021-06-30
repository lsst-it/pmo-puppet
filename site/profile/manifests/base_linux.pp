# Base profile for Linux OS
class profile::base_linux {
  include network
  include ::firewalld
  include ssh
  include accounts
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
  'wget', 'nmap', 'iputils', 'bind-utils', 'traceroute' ]:
  ensure => installed,
  }
# Modify these files to secure servers
$sshd_banner = lookup('sshd_banner')
file { '/etc/ssh/sshd_banner' :
  ensure  => file,
  content => $sshd_banner,
}
$denyhosts = lookup ('denyhosts')
file { '/etc/hosts.deny' :
  ensure  => file,
  content => $denyhosts,
}
$allowhosts = lookup ('allowhosts')
file { '/etc/hosts.allow' :
  ensure  => file,
  content => $allowhosts,
}
}
