class profile::base_confluence {
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
     # Does Confluence need this package mysql57-community-release
  class { 'mysql::server':
      package_name => 'mysql-community-server', package_ensure => '5.7.35-1.el7', service_name => 'mysqld', root_password => 'thisisthat^',
      override_options => { mysqld => { log-error => '/var/log/mysqld.log', } },
      restart => true,
  }
  mysql_user { 'confluence@localhost': ensure => present, password_hash => mysql::password('Some1New^'),}
  mysql::db { 'confluence': user => 'confluence', password => 'Some1New^', host => 'localhost', grant => ['ALL'], collate => 'utf8_bin', }

## Nginx
  Package { [ 'nginx', ]: ensure => installed, }
  #Package { [ 'nginx-filesystem', 'nginx-mod-http-perl', 'nginx-mod-mail', 'nginx-mod-stream', 'nginx-all-modules', 'nginx-mod-http-xslt-filter', 'nginx-mod-http-image-filter', ]: ensure => installed, }
  firewalld_service { 'Allow http on public zone': ensure => 'present', service => 'http', zone => 'public', }
  firewalld_service { 'Allow https on public zone': ensure => 'present', service => 'https', zone => 'public', }
  #firewalld_port { 'Allow https on public zone': ensure => 'present', port => '8090', protocol => 'tcp', zone => 'public', 
  } # end of Nginx


## other notes or actions to get into this file
# Need to transfer the backup data sets 
# Need to package up sirius:/home/igoodenow/recovery-audit-3Nov2021/confluence/atlassian-confluence-7.11.6-x64.bin
# Need to package up mysql-connector-java-5.1.27-bin.jar; it is in install backup; belongs in /opt/atlassian/confluence/confluence/WEB-INF/lib/
 # May need to change owner
 # chown confluence:confluence /opt/atlassian/confluence/confluence/WEB-INF/lib/mysql-connector-java-5.1.27-bin.jar
# May choose to do a check point before starting this process

# Configure MySQL my.cnf values
 # https://github.com/igoodenow/services/blob/master/service-confluence/confluence-configurations/etc/my.cnf
 # the above should be production branch when not testing
 # systemctl status mysqld
 # systemctl is-enabled mysqld
 # systemctl enable mysqld
 # systemctl start msyqld
 # systemctl restart mysqld
# Create the Sample certs or apply real certs
 # openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /etc/pki/tls/certs/sample.crt -keyout /etc/pki/tls/certs/sample.key
# Restore/Update nginx conf
 # https://github.com/igoodenow/services/blob/master/service-confluence/confluence-configurations/nginx/conf.d/hephaestuscrimson.conf
 # Check on location and name of certs and keys used for each vhost
 # setsebool -P httpd_can_network_connect 1
 # setsebool -P httpd_can_network_relay 1
 # nginx -t
 # systemctl status nginx
 # systemctl is-enabled nginx
 # systemctl enable nginx
 # systemctl status nginx
 # systemctl start nginx
  #or
  # systemctl restart nginx
# For Testing Purposes otherwise DNS needs to be correct
 # vi /etc/nsswitch.conf
 # hosts: files dns myhostname
 # vi /etc/hosts
 # 127.0.0.1 confluence.lsstcorp.org
# yum groupinstall "GNOME Desktop"
# Install Fresh Confluence
 # ./atlassian-confluence-7.11.6-x64.bin
 # go with defaults
 # install as a service
 # do NOT let it start or stop it if started
 # copy the sourced mysql-connector-java-5.1.27-bin.jar to /opt/atlassian/confluence/confluence/WEB-INF/lib/
# Because of systemctl issues, need to protect test from production by not allowing it to start
 # mv /opt/atlassian/confluence/bin/start-confluence.sh /opt/atlassian/confluence/bin/start-confluence_.sh

# Test Base Install of Confluence using HV console or do local hosts changes to bypass DNS
 # HV Console
 # startx
 # start a terminal with elevated privs
 # Start Confluence fresh install
  # /opt/atlassian/confluence/bin/start-confluence_.sh
 # Launch local browser and access web sites
  # http://localhost:8090
  # https://confluence.lsstcorp.org
  # Expect cert errors
# Test access
# Stop Confluence
 # /opt/atlassian/confluence/bin/stop-confluence.sh
 # ps axu|grep confluence
# Protect Production by restricting network on recovery host
 # vi /etc/sysconfig/network-scripts/ifcfg-eth0
 # ONBOOT="no"
# Restore Production Backups
 # Need mysql dump name and make sure to have procedure dump
  # https://confluence.atlassian.com/confkb/confluence-mysql-database-migration-causes-content_procedure_for_denormalised_permissions-does-not-exist-error-1072474724.html
 # gunzip < /home/igoodenow_local/atlassian-confluence-mysql-YYYYMMDDHHMMSS.sql.gz | mysql confluence
 # cd /var/atlassian/application-data/confluence
 # tar -xzvf /home/igoodenow_local/atlassian-confluence-home-YYYYMMDDHHMMSS.tgz
 # rm -rf plugins-cache*
 # rm -rf plugins-osgi-cache*
 # rm -rf plugins-temp*
 # rm -rf bundled-plugins*
 # Reset admin password
  # mysql
  # use confluence;
  # select u.id, u.user_name, u.active from cwd_user u join cwd_membership m on u.id=m.child_user_id
  # join cwd_group g on m.parent_id=g.id join cwd_directory d on d.id=g.directory_id where g.group_name = 'confluence-administrators' and d.directory_name='Confluence Internal Directory';
  # update cwd_user set credential = 'googlethepassword' where id=XXXXXX;
  # exit
 # Update confluence db file with mysql confluence password
  # vi /var/atlassian/application-data/confluence/confluence.cfg.xml

# Access HV Console while in restricted network access
 # Stop Confluence 
  # systemctl stop confluence
  # /opt/atlassian/confluence/bin/stop-confluence.sh
  # ps axu|grep confluence

 
 
# special start
   #ifconfig|less
   #ifconfig eth0 down
   #ping www.cnet.com
   #systemctl start confluence
   #tail -f /opt/atlassian/confluence/logs/catalina.out
 #  console
#startx
#ping www.cnet.com
#ifup eth0
#ifconfig eth0 down
#ping www.cnet.com

#start confluence
#/opt/atlassian/confluence/bin/start-confluence_.sh
#got login
#have captcha
#https://confluence.lsstcorp.org
#system report?
#all good
#still getting the loading the editor error
#i think it is a db error based on
#"...bad SQL grammar... confluence.cnetnet_procedure_for_denormalised_permissions does not exit..."

#https://confluence.atlassian.com/confkb/confluence-mysql-database-migration-causes-content_procedure_for_denormalised_permissions-does-not-exist-error-1072474724.html
#seemt like it could fix the problem; stored

#show procedure status where db='confluence';
#on producton shows stuff; on recovery nothing there




# perms have proper grant
# tar -xzvf atlassian-confluence-install-20210731064501.tgz --wildcards --no-anchored 'mysql*java*.jar'
# cp /install/confluence/WEB-INF/lib/mysql-connector-java-5.1.27-bin.jar /opt/atlassian/confluence/confluence/WEB-INF/lib/
# chown and selinxu
# drop logs and cache
# rm -rf  *_broken and from production so not transferred
# confluence.cfg.xml
# Restore install config changes
# https://confluence.atlassian.com/confkb/confluence-mysql-database-migration-causes-content_procedure_for_denormalised_permissions-does-not-exist-error-1072474724.html
# Remove this profile from node.


# Commands once needed
# Prove certains packages are not installed
 # rpm -qa|grep -e 'mysql\|java\|nginx'|sort
 # yum repolist
# what char set mysql -e "create database confluence CHARACTER SET utf8 COLLATE utf8_bin;
# update mysql.user set authentication_string = PASSWORD('newpassword^'), password_expired ='N' where User = 'root' and Host = 'localhost';
# temp firewall firewall-cmd --zone=public --add-port=8090/tcp