class profile::base_drupal {
  yumrepo { 'epel': 
    enabled => 1, 
    descr => 'epel',
    metalink => 'https://mirrors.fedoraproject.org/metalink?repo=epel-7&arch=$basearch&infra=$infra&content=$contentdir', 
    gpgcheck => 0,
  } # end of yumrepo
  yumrepo { 'remi-php72': 
    enabled => 1, 
    descr => 'remi-php72',
    mirrorlist => 'http://cdn.remirepo.net/enterprise/7/php72/mirror', 
    gpgcheck => 0,
  } # end of yumrepo
   yumrepo { 'remi-safe': 
    enabled => 1, 
    descr => 'remi-safe',
    mirrorlist => 'http://cdn.remirepo.net/enterprise/7/safe/mirror', 
    gpgcheck => 0,
  } # end of yumrepo  

  # MySQL   
  # Action -  Need to get 10.2 running; not 10.4 done by below
    class { 'mariadb::server': repo_version => '10.2', root_password => 'yeah#doit', }
    mysql_user { 'drupal-dbuser@localhost': ensure => present, password_hash => mysql::password('ItIsThis^'),}
    mysql::db { 'drupaltest': user => 'drupal-dbuser', password => 'ItIsThis^', host => 'localhost', grant => ['ALL'], }
  # httpd
  Package { [ 'httpd', ]: ensure => installed, }
  Package { [ 'mod_ssl', 'mod_nss', ]: ensure => installed, }

  # PHP
  Package { [ 'php72.x86_64', ]: ensure => installed, }
  Package { [ 'php72-php-process', 'php72-php-tidy', 'php72-php-imap', ]: ensure => installed, }
  Package { [ 'php-cli', 'php-gd', 'php-mbstring', 'php-ldap', 'php-pdo', 'php-soap', 'php-xml', 'php-tidy', 'php-xmlrpc', 'php-bcmath', 'php-mysqlnd', 'php-pecl-mcrypt', 'php-pecl-zip', ]: ensure => installed, }
  # Not sure if these are necessary
#php-fedora-autoloader-1.0.1-2.el7.noarch
#php-php-gettext-1.0.12-1.el7.noarch
#php-PsrLog-1.1.3-1.el7.noarch
#php-symfony-class-loader-2.8.12-2.el7.noarch
#php-symfony-common-2.8.12-2.el7.noarch
#php-symfony-css-selector-2.8.12-2.el7.noarch
#php-tcpdf-6.2.26-1.el7.noarch
#php-tcpdf-dejavu-sans-fonts-6.2.26-1.el7.noarch
  Package { [ 'phpMyAdmin', ]: ensure => installed, }

  # Drush
  Package { [ 'drush', ]: ensure => installed, }

  # Manual steps to be converted to puppet
  # systemctl is-enabled httpd
  # systemctl status httpd
  # firewall-cmd --zone=public --add-service=http
  # firewall-cmd --zone=public --add-service=https
  # systemctl start httpd
  # systemctl status httpd
  # check if testing page is available
  # echo "<html><body>something</body></html>" > /var/www/html/index.htm
  # echo "<?php phpinfo();?>" > /var/www/html/index.php
  # show as html
  # php -v
  # cd /install/
  # tar -xzvf php-4-zig.tgz
  # mv lib* /etc/httpd/modules/
  # chown root:root /etc/httpd/modules/libphp7.so /etc/httpd/modules/libphp7-zts.so
  # chcon system_u:object_r:httpd_modules_t:s0 /etc/httpd/modules/libphp7.so
  # chcon system_u:object_r:httpd_modules_t:s0 /etc/httpd/modules/libphp7-zts.so
  # chcon system_u:object_r:httpd_modules_t:s0 /etc/httpd/modules/libmodnss.so
  # systemctl restart httpd
  # systemctl status httpd
  # vi /etc/httpd/conf.modules.d/15-php.conf
  # vi /etc/httpd/conf.d/php.conf
  # systemctl restart httpd
  # mkdir -p /install/drupal
  # cd /install/drupal/
  # wget https://ftp.drupal.org/files/projects/drupal-7.82.tar.gz
  # tar -xzvf drupal-7.82.tar.gz
  # cd /var/www/html/
  # cp -R /install/drupal/drupal-7.82 /var/www/html/
  # ln -s ./drupal-7.82 ./drupaltest
  # ACTION - Need to enable and start httpd service
  # ACTION - Need to create the two firewall holes if not already exist
  
  # cd /var/www/html/drupal-7.82/
  # mkdir -p sites/default/files
  # chmod 775 sites/default/files
  # chmod 777 sites/default/files

  # cp -p sites/default/default.settings.php sites/default/settings.php
  # chmod 664 sites/default/settings.php
  # chgrp -R apache /var/www/html/drupal-7.82/
  # needed to disable selinux to get past files; 
  # added db info from 

  # site is done
  # chmod 644 sites/default/settings.php
  # need to fix selinux for files directory
  # needs permissive to clear errors

  # openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /etc/pki/tls/certs/sample.crt -keyout /etc/pki/tls/certs/sample.key
  # need hte php4-zig.tgz that contains lib* modules for httpd/conf.modules
  # need postfix installed and configured
  
# Remove this profile from node.




}
