class profile::base_jira {
  # Configure Yum Repos and Install Packages
  yumrepo { 'epel':
    enabled => 1,
    descr => 'epel',
    metalink => 'https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch&infra=$infra&content=$contentdir',
    gpgcheck => 0,
  } # end of yumrepo
  yumrepo { 'nginx':
    enabled => 1,
    descr => 'Nginx',
    baseurl => 'http://nginx.org/packages/mainline/centos/7/$basearch/',
    gpgcheck => 0,
  } # end of yumrepo
  yumrepo { 'mysql57-community':
    enabled => 1,
    descr => 'mysql-57',
    baseurl => 'http://repo.mysql.com/yum/mysql-5.7-community/el/7/$basearch/',
    gpgcheck => 0,
  } # end of yumrepo
  yumrepo { 'mysql-tools-community':
    enabled => 1,
    descr => 'mysql-tools-community',
    baseurl => 'http://repo.mysql.com/yum/mysql-tools-community/el/7/$basearch/',
    gpgcheck => 0,
  } # end of yumrepo
  yumrepo { 'mysql-connectors-community':
    enabled => 1,
    descr => 'mysql-connectors-community',
    baseurl => 'http://repo.mysql.com/yum/mysql-connectors-community/el/7/$basearch/',
    gpgcheck => 0, 
  } # end of yumrepo

## Java
  package { [ 'java-1.8.0-openjdk', 'java-1.8.0-openjdk-devel', 'java-1.8.0-openjdk-headless', 'javapackages-tools', ]: 
    ensure => installed, 
  } # end of Java

## MySQL
     # Does Jira need this package mysql57-community-release
  class { 'mysql::server':
      package_name => 'mysql-community-server', package_ensure => '5.7.35-1.el7', service_name => 'mysqld', root_password => 'thisisthat^',
      override_options => { mysqld => { log-error => '/var/log/mysqld.log', } },
      restart => true,
  }
  mysql_user { 'jira@localhost': ensure => present, password_hash => mysql::password('jjSome1New^'),}
  mysql::db { 'jira': user => 'jira', password => 'jjSome1New^', host => 'localhost', grant => ['ALL'], collate => 'utf8_bin', }
  # tighten up perms from notes

## Nginx
  Package { [ 'nginx', ]: ensure => installed, }
  #Package { [ 'nginx-filesystem', 'nginx-mod-http-perl', 'nginx-mod-mail', 'nginx-mod-stream', 'nginx-all-modules', 'nginx-mod-http-xslt-filter', 'nginx-mod-http-image-filter', ]: ensure => installed, }
  firewalld_service { 'Allow http on public zone': ensure => 'present', service => 'http', zone => 'public', }
  firewalld_service { 'Allow https on public zone': ensure => 'present', service => 'https', zone => 'public', }
  #firewalld_port { 'Allow https on public zone': ensure => 'present', port => '8080', protocol => 'tcp', zone => 'public', 
  } # end of Nginx

## Other actions or notes to update this file
# May choose to create a checkpoint now or after the long download ang GNome Desktop installation
# Need to tranfer files
 # Package up files or
 # scp -i ~/.ssh/localkey /home/igoodenow/recovery-audit-3Nov2021/jira/mysql-connector-java-5.1.27-bin.jar igoodenow_local@140.252.33.50:/home/igoodenow_local/
 # scp -i ~/.ssh/localkey /home/igoodenow/recovery-audit-3Nov2021/jira/atlassian-jira-software-8.13.10-x64.bin igoodenow_local@140.252.33.50:/home/igoodenow_local/
# Need to Configure AWS and transfer backup set
 # cd ~igoodenow_local
 # curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
 # unzip awscliv2.zip
 # aws/install
 # aws configure
 # https://my.1password.com/vaults/sv63i4a7gaeksvzc3kymnerliy/allitems/lgtogm4g53uimqkw7gyw4q2eoy
 # aws s3 cp s3://<somebucket> /destination
# May need to check mysql, java, nginx versions are installed
# yum groupinstall "GNOME Desktop"
# Edit my.cnf file
 # https://github.com/igoodenow/services/blob/master/service-jira/jira-configurations/etc/my.cnf
 # the above should be production branch when not testing
 # systemctl status mysqld
 # systemctl is-enabled mysqld
 # systemctl enable mysqld
 # systemctl start msyqld
 # systemctl restart mysqld
# Create the Sample certs or apply real certs
 # openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /etc/pki/tls/certs/sample.crt -keyout /etc/pki/tls/certs/sample.key
# Restore/Update nginx conf
 # https://github.com/igoodenow/services/blob/master/service-jira/jira-configurations/nginx/conf.d/hephaestusvermillion.lsst.org.conf
 # Check on location and name of certs and keys used for each vhost
 # setsebool -P httpd_can_network_connect 1
 # setsebool -P httpd_can_network_relay 1
 # nginx -t
 # systemctl status nginx
 # systemctl is-enabled nginx
 # systemctl enable nginx
 # systemctl status nginx
 # systemctl start nginx
# For Testing Purposes otherwise DNS needs to be correct
 # vi /etc/nsswitch.conf
 # hosts: files dns myhostname
 # vi /etc/hosts
 # 127.0.0.1 confluence.lsstcorp.org
# Fresh Install of Jira
 # ./atlassian-jira-software-8.13.10-x64.bin
 # go with defaults
 # install as a service
 # do NOT let it start or stop it if started
 # cp -p mysql-connector-java-5.1.27-bin.jar /opt/atlassian/jira/lib/
# Because of systemctl issues, need to protect test from production by not allowing it to start
# service does not behave as expected; chkconfig vs systemctl; not sure if gold standard is different
 # mv /opt/atlassian/jira/bin/start-jira.sh /opt/atlassian/jira/bin/start-jira_.sh

# Test Base Install of Jira using HV console or do local hosts changes to bypass DNS
 # HV Console
 # startx
 # start a terminal with elevated privs

# Start Jira Fresh install
 # /etc/init.d/jira start
  # or
  # /opt/atlassian/jira/bin/start-jira_.sh
  

# Launch local browser and access web sites
  # http://localhost:8080
  # https://jira.lsstcorp.org
  # Expect cert errors
# Test access
# Stop Jira
 # /etc/init.d/jira stop 
  # or
  # /opt/atlassian/jira/bin/stop-jira.sh

# Protect Production by restricting network on recovery host
 # vi /etc/sysconfig/network-scripts/ifcfg-eth0
 # ONBOOT="no"

# Restore Production Backups
 # Need mysql dump name
 # gunzip < /home/igoodenow_local/atlassian-jira-mysql-YYYYMMDDHHMMSS.sql.gz | mysql jira
 # cd /var/atlassian/application-data/jira
 # tar -xzvf /home/igoodenow_local/atlassian-jira-home-YYYYMMDDHHMMSS.tgz
 # Reset admin password
  # mysql
  # use jira;
  # select u.id, u.user_name, u.active from cwd_user u join cwd_membership m on u.id=m.child_user_id
  # join cwd_group g on m.parent_id=g.id join cwd_directory d on d.id=g.directory_id where g.group_name = 'jira-administrators' and d.directory_name='Jira Internal Directory';
  # update cwd_user set credential = 'googlethepassword' where id=XXX;
  # exit
 # Update confluence db file with mysql confluence password
  # vi /var/atlassian/application-data/jira/dbconfig.xml


# Access HV Console while in restricted network access
 # Stop Jira 
  # systemctl stop jira
  # /opt/atlassian/confluence/bin/stop-jira.sh
  # ps axu|grep jira 
  # special start
   # ifconfig|less
   # ifconfig eth0 down
   # ping www.cnet.com
   # systemctl start jira
   # tail -f /opt/atlassian/jira/logs/catalina.out
   # startx
   # ping www.cnet.com

# start Jira
  # systemctl start jira;tail -f /opt/atlassian/logs/catalina.out
  # tail -f /opt/atlassian/logs/catalina.out
  # tail -f /opt/atlassian/log/catalina.out
  # systemctl status jira
  # tail -f /opt/atlassian/jira/logs/catalina.out
  # http://locahost:8080
  # https://jira.lsstcorp.org
  # Can you login?
  # system report?

# ping www.cnet.com
# ifconfig eth0
# ifconfig eth0 down
# ping www.cnet.com
  # the above is to prevent jira processing email or other network interactions
  # prevents testing ldap

# need ./lib/mysql-connector-java-5.1.27-bin.jar
# verify mysql -e "alter database jira character set utf8mb4 collate utf8mb4_bin;"
# dbconfig.xml file needs the jira db username and password
# on sirius zig-zrecover-jira-notes.tgz  has files
# nsswitch and hosts need special changes to do testing w/o network dns
# tar -xzvf atlassian-jira-install-20211102064518.tgz --wildcards "*mysql-connector-java-5.1.27-bin.jar"
# Restore install config changes
# Remove this profile from node.

## Commands No Longer needed
# rpm -qa|grep -e 'mysql\|java\|nginx'|sort
# yum repolist
# 