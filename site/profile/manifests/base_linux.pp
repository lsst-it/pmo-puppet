# Base profile for Linux OS
# @param backups
#  If true will deploy backup scripts
# @param awscli
#  If true will install and configure awscli
# @param postfix
#  If `true`, configure postfix
# @param graylog
#  If `true`, configure graylog
class profile::base_linux (
  Boolean $awscli  = false,
  Boolean $backups = false,
  Boolean $postfix = false,
  Boolean $graylog = false,
) {
  include network
  include ::firewalld
  include ssh
  include cron
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
    version       => '1.5.0',
    extra_options => '--collector.systemd \--collector.processes \--collector.meminfo_numa',
  }
  class { 'chrony':
    servers => ['140.252.1.140', '140.252.1.141', '0.pool.ntp.arizona.edu'],
  }
  class { 'timezone':
    timezone => 'UTC',
  }

  Package {['git', 'tree', 'tcpdump', 'telnet', 'gcc', 'xinetd',
      'bash-completion', 'sudo', 'vim', 'openssl', 'openssl-devel',
    'wget', 'nmap', 'iputils', 'bind-utils', 'traceroute', 'unzip', 'net-tools']:
      ensure => installed,
  }
  if $awscli {
    Package {['python3-pip', 'python3-devel']:
      ensure => installed,
    }
    exec { 'Install awscli':
      path    => ['/usr/bin', '/bin', '/usr/sbin'],
      command => 'sudo pip3 install awscli',
      onlyif  => '/usr/bin/test ! -x /usr/local/bin/aws',
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
