class profile::base_yourls {
## Can get specific files from github if files backup is not available
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
  yumrepo { 'remi-php73': 
    enabled => 1, 
    descr => 'remi-php73',
    mirrorlist => 'http://cdn.remirepo.net/enterprise/7/php73/mirror', 
    gpgcheck => 0,
  } # end of yumrepo
   yumrepo { 'remi-safe': 
    enabled => 1, 
    descr => 'remi-safe',
    mirrorlist => 'http://cdn.remirepo.net/enterprise/7/safe/mirror', 
    gpgcheck => 0,
  } # end of yumrepo
 
  # MySQL   
    class { 'mariadb::server': root_password => 'yeah#doit', }
    mysql_user { 'yourls@localhost': ensure => present, password_hash => mysql::password('itisthis^'),}
    mysql::db { 'yourls': user => 'yourls', password => 'itisthis^', host => 'localhost', grant => ['ALL'], }
    # no checks defined to test mysql users later

  # Nginx
  Package { [ 'nginx-1.20.1-9.el7.x86_64', ]: ensure => installed, }
  Package { [ 'nginx-filesystem', 'nginx-mod-http-perl', 'nginx-mod-mail', 'nginx-mod-stream', 'nginx-all-modules', 'nginx-mod-http-xslt-filter', 'nginx-mod-http-image-filter', ]: ensure => installed, }
  firewalld_service { 'Allow http on public zone': ensure => 'present', service => 'http', zone => 'public', }
  firewalld_service { 'Allow https on public zone': ensure => 'present', service => 'https', zone => 'public', }

# run this to get a test cert
# openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /etc/pki/tls/certs/sample.crt -keyout /etc/pki/tls/certs/sample.key
# setenforce 0 until key/cert is fixed
  #service { 'nginx.service': ensure => 'running', }
  #include nginx
  # nginx::resource::server { 'zig-mysql.lsst.local':
  #   ensure => present,
  #   www_root => '/usr/share/nginx/html',
  #   ssl => true,
  #   listen_port => 443, #need to check this 
  #   ssl_cert => '/etc/pki/tls/certs/sample.crt', # fix selinux, location, requires the files
  #   ssl_key => '/etc/pki/tls/certs/sample.key', 
  #   server_name => ['zig-mysql.lsst.local'],
  # } # end of nginx resource server

# NEED to run recompile steps
  Package { [ 'openldap-devel', 'git', ]: ensure => installed, }
  # cd ~
  # wget https://nginx.org/download/nginx-1.20.1.tar.gz
  # tar -xzvf nginx-1.20.1.tar.gz
  # cd nginx-1.20.1
  # git clone https://github.com/kvspb/nginx-auth-ldap.git
  # ./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --error-log-path=/var/log/nginx/error.log --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --user=nginx --group=nginx --add-module=./nginx-auth-ldap --with-http_ssl_module
  # make
  # make install
  # /usr/sbin/nginx -V
  # find /  -name index.html
  # /etc/nginx/html/index.html
  # /usr/share/nginx/html/index.html
  # which one is the default root of this nginx service?

  # systemctl status nginx
  # less /usr/lib/systemd/system/nginx.service
  # using expected binary file
  # Based on troubleshooting
  # /etc/nginx/conf/nginx.conf is the assume and thus edit 
  # /etc/nginx/html/index.html
  # vi /etc/nginx/html/index.html
  # change Welcome so it is Working Welcome
  # systemctl is-enabled nginx
  # systemctl enable nginx
  # systemctl start nginx
  # http://140.252.33.21
  # Working Welcome
  # https://140.252.33.21
  # failed; ssl not configured so no surprise
  # rpm -qa|grep -i 'nginx\|mariadb\|php'
  # mariadb and  several nginx packages

  # PHP

  Package { [ 'php-7.3.32-1.el7.remi.x86_64', ]: ensure => installed, }
  Package { [ 'php-devel', 'php-common', 'php-cli', 'php-process', ]: ensure => installed, } 
  Package { [ 'php-json', 'php-pecl-apcu', 'php-fpm', 'php-pecl-mcrypt', 'oniguruma5php', 'php-pecl-apcu-devel', 'php-pecl-zip', 'php-fedora-autoloader', 'php-xml', ]: ensure => installed, }
  Package { [ 'php-mysqlnd', 'php-mbstring', 'php-pear', 'php-pdo', 'php-bcmath', 'php-gd', ]: ensure => installed, }

  # Need working root directory of nginx for two lines below that assume /etc/nginx/html/
  # echo "<?php phpinfo(); ?>" > /etc/nginx/html/phpinfo.php
  # php /etc/nginx/html/phpinfo.php
  # the commands after the vi of www.conf are vi statements to delete lines
  # vi /etc/php-fpm.d/www.conf
  # 3dd
  # move to below [www]
  # 46dd
  # should be left with stuff below starting with 
  # ; When POSIX Access Control Lists are supported you can set them using
  # add
  # user = nginx
  # group = nginx
  # listen = /var/run/php-fpm/php7.2-fpm.sock
  # listen.owner = nginx
  # listen.group = nginx
  # listen.mode = 0660
  # ACTION - if referenced fix below is done, need to adjust above as well
  # Assumes conf is /etc/nginx/conf/nginx.conf
  # vi /etc/nginx/conf/nginx.conf
  # add beow the location / {}
  # 
  #         location ~ \.php$ {
  #         try_files $uri =404;
  #         include /etc/nginx/fastcgi.conf;
  #         fastcgi_pass unix:/var/run/php-fpm/php7.2-fpm.sock;
  #        }
  # vi /etc/nginx/conf/nginx.conf
  # added at outside end of server {} 
  #     include /etc/nginx/conf.d/*.conf;
  # NEED TO KNOW LDAP INFO
  # https://my.1password.com/vaults/sv63i4a7gaeksvzc3kymnerliy/allitems/upzgyet4oukr7io4shr7ae7p6a
  # add in http but before server{}
  #     ldap_server ldap01 {
  #         url "ldap://ldap.XXX.YYY/CN=users,DC=XXX,DC=YYY?sAMAccountName?sub?(objectClass=*)";
  #         binddn "cn=FIRST LAST,cn=users,dc=XXX,dc=YYY";
  #         binddn_passwd "xxyy";
  #         require valid_user;
  #         satisfy any;
  #     }
  # use content from https://github.com/igoodenow/service_yourls/blob/main/nginx/conf.d/yourls.conf 
  # to create yourls.conf
  # vi /etc/nginx/conf.d/yourls.conf
  # however need to make fixes
  # 3 eidts changed from old sock path to new php-fpm path
  # /var/run/php-fpm/php7.2-fpm.sock
  # ACTION - Update the file to remove this step; not it is NOT the same as Production
  # ACTION - update the name to be php7.3 if it doesn't cause problems
  # May have already run the openssl to create certs; no need 2nd time so check location
  # openssl req -newkey rsa:4096 -x509 -sha256 -days 3650 -nodes -out /etc/pki/tls/certs/sample.crt -keyout /etc/pki/tls/certs/sample.key
  # systemctl status php-fpm.service
  # systemctl is-enabled php-fpm.service
  # systemctl enable php-fpm.service
  # nginx -t
  # systemctl stop php-fpm.service; systemctl stop nginx; systemctl start nginx; systemctl start php-fpm.service
  # http://<IP>/phpinfo.php
  # page show up?

  # YOURLS
  # cd ~
  # https://github.com/YOURLS/YOURLS/releases/tag/1.7.4
  # wget -O ~/yourls.tar.gz https://github.com/YOURLS/YOURLS/archive/refs/tags/1.7.4.tar.gz
  # gunzip ~/yourls.tar.gz;cd /etc/nginx/;tar -xvf ~/yourls.tar;ln -s ./YOURLS-1.7.4 YOURLS
  # cd /etc/nginx/YOURLS/;cp user/config-sample.php user/config.php
  # vi user/config.php
  # edit file now but need senstive info passed
  # lines 14, 17, 35 
  ## need values for YOURLS_DB_USER, DB_PASS, DB_NAME, DB_HOST, DB_PREFIX '', _SITE 
  ## db_pass is referenced in mysql::db
  # your host ready?
  # alter your computer's host file and prepare private browser
  # ping ls.st
  # the test guest ip returned? 
  # https://ls.st
  # cert error
  # no page
  # no index.html exists so go to /admin
  # https://ls.st/admin
  # perform the install from the web page link
  # do htaccess step referenced on the wizard page
  # login with defaults in user/config.php

## Restoring Production Data from AWS Backup Set
  # yum install unzip
  # cd  ~
  # curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  # unzip awscliv2.zip
  # aws/install
  # need creds frm https://my.1password.com/vaults/sv63i4a7gaeksvzc3kymnerliy/allitems/lgtogm4g53uimqkw7gyw4q2eoy 
  # aws configure
  # cd ~
  # aws s3 cp s3://yourls-data/mysql-db-yourls-2021XXXX ~/
  # aws s3 cp s3://yourls-data/config-yourls-2021XXXX ~/
  # gunzip mysql-db-yourls-202110XXXXX
  # mysql yourls < mysql-db-yourls-202110XXXXX
  # tar -xzvf config-yourls-202111150300.tgz
  # cp -rp /root/nginx/YOURLS/* /etc/nginx/YOURLS/
  # set overwrite to bypass prompt
  #go back to fix db password
  # vi /etc/nginx/YOURLS/user/config.php
  # https://ls.st/admin/
  # Should get ldap prompt
  # should work
  # should see urls from last day of backup
  # Check active plugins is 6
  
# ACTION - Combine the guzip and import into one statement
# ACTION - fix the backup script to add .sql extentions
# ACTION - Fix Production Backups to Include the image files in YOURLS
# ACTION - Store source install on production server as part of backup set

} # end of base_yourls 
