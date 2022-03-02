# Base profile for Linux OS
class profile::base_linux (
  Boolean $awscli  = false,
  Boolean $postfix = false,
  Boolean $graylog = false,
) {
  include network
  include ::firewalld
  include ssh
  include accounts
  if $postfix {
  include postfix
  }
  if $graylog {
  include rsyslog
  include rsyslog::config
  }
# config: /etc/systemd/system/node_exporter.service
  class { 'prometheus::node_exporter':
    version       => '1.1.2',
    extra_options => '--collector.systemd \--collector.processes \--collector.meminfo_numa',
  }
  class { 'chrony':
    servers => [ '140.252.1.140', '140.252.1.141', '0.pool.ntp.arizona.edu' ],
  }
  class { 'timezone':
      timezone => 'UTC',
  }

  Package { [ 'git', 'tree', 'tcpdump', 'telnet', 'gcc', 'xinetd',
  'bash-completion', 'sudo', 'vim', 'openssl', 'openssl-devel',
  'wget', 'nmap', 'iputils', 'bind-utils', 'traceroute', 'unzip' ]:
    ensure => installed,
  }
  if $awscli {
  Package { [ 'awscli' ]:
    ensure => installed,
  }
  $awscreds = lookup('awscreds')
    file {
      '/root/.aws':
        ensure => directory,
        mode   => '0700',
        ;
      '/root/.aws/credentials':
        ensure  => file,
        mode    => '0600',
        content => $awscreds,
        ;
      '/root/.aws/config':
        ensure  => file,
        mode    => '0600',
        content => "[default]\n",
    }
  }
# Modify these files to secure servers
  $host = lookup('host')
  file { '/etc/host.conf' :
    ensure  => file,
    content => $host,
  }
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
