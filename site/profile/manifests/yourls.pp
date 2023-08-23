# URL Shortener.  Use dnf install nginx instead of the module as it needs to be recompiled. 
# Ensure PHP 8.2 is installed: dnf install dnf-utils http://rpms.remirepo.net/enterprise/remi-release-8.rpm -- dnf install  php php-fpm php-cli php-devel php-mbstring php-gd php-xml php-curl php-mysqlnd php-pdo php-json php-opcache php-pear php-pecl-apcu php-pecl-crypto
class profile::yourls (Sensitive[String]
$yourls_db_pass_hide,
$yourls_db_user_hide,
$yourls_version,
$nginx_version,

){
include mysql::server

  Package { [ 'openldap-devel', 'make', 'yum-utils', 'pcre-devel', 'epel-release' ]:
    ensure => installed,
  }
  unless $::nginx_source  {
    archive { "/usr/src/nginx-${nginx_version}.tar.gz":
      ensure       => present,
      source       => "http://nginx.org/download/nginx-${nginx_version}.tar.gz",
      extract_path => '/usr/src',
      extract      => true,
      provider     => 'wget',
      cleanup      => false,
    }
    vcsrepo { "/usr/src/nginx-${nginx_version}/nginx-auth-ldap":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/kvspb/nginx-auth-ldap.git',
      user     => 'root',
    }
    vcsrepo { "/etc/nginx/YOURLS-${yourls_version}":
      ensure   => present,
      provider => git,
      source   => 'https://github.com/YOURLS/YOURLS.git',
      user     => 'root',
    }
    archive { '/tmp/yourls_config.zip' :
      ensure       => present,
      source       => 's3://urlshortener-data/yourls_config.zip',
      cleanup      => false,
      extract      => true,
      extract_path => '/tmp',
    }
    archive { '/tmp/mysql-db-yourls.gz' :
      ensure  => present,
      source  => 's3://urlshortener-data/mysql-db-yourls-latest.gz',
      cleanup => false,
    }
    $yourls_db_name = lookup('yourls_db_name')
    mysql::db { $yourls_db_name:
      user           => $yourls_db_user_hide.unwrap,
      password       => $yourls_db_pass_hide.unwrap,
      host           => 'localhost',
      grant          => ['ALL'],
      sql            => ['/tmp/mysql-db-yourls.gz'],
      import_cat_cmd => 'zcat',
      import_timeout => 900,
    }
  }
# Installs plugins. some plugins need to be activated in GUI
    file {
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/mass-remove-links":
        ensure => directory,
        ;
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/mass-remove-links/plugin.php":
        ensure => file,
        source => '/tmp/mass-remove-links-plugin.php',
        ;

      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/preview-url":
        ensure => directory,
        ;
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/preview-url/plugin.php":
        ensure => file,
        source => '/tmp/preview-url-plugin.php'
        ;

      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/show-plugin":
        ensure => directory,
        ;
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/show-plugin/plugin.php":
        ensure => file,
        source => '/tmp/show-plugin-plugin.php'
        ;

      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/yourls-preview-url-with-qrcode":
        ensure => directory,
        ;
      "/etc/nginx/YOURLS-${yourls_version}/user/plugins/yourls-preview-url-with-qrcode/plugin.php":
        ensure => file,
        source => '/tmp/yourls-preview-url-with-qrcode-plugin.php'
        ;
# Shorten directory
      "/etc/nginx/YOURLS-${yourls_version}/shorten":
        ensure => directory,
        ;
    }
  file { '/etc/nginx/YOURLS':
    ensure => 'link',
    target => "/etc/nginx/YOURLS-${yourls_version}",
  }

  archive { '/etc/pki/tls/certs/ls.st.current.crt' :
    ensure  => present,
    source  => 's3://urlshortener-data/ls.st.current.crt',
    cleanup => false,
  }
  archive { '/etc/pki/tls/certs/ls.st.current.key' :
    ensure  => present,
    source  => 's3://urlshortener-data/ls.st.current.key',
    cleanup => false,
  }

  archive { "/etc/nginx/YOURLS-${yourls_version}/yourls-logo.png":
    ensure  => present,
    source  => 's3://urlshortener-data/yourls-logo.png',
    cleanup => false,
  }
  # archive { "/etc/nginx/YOURLS-${yourls_version}/Telescope_Front-470.jpg":
  #   ensure  => present,
  #   source  => 's3://urlshortener-data/Telescope_Front-470.jpg',
  #   cleanup => false,
  # }

  archive { "/etc/nginx/YOURLS-${yourls_version}/Telescope_Front-470.jpg":
    ensure  => present,
    source  => 'https://www.lsst.org/sites/default/files/Wht-Logo-web_0.png',
    cleanup => false,
  }
  $phpinfo = lookup ('phpinfo')
  file { "/etc/nginx/YOURLS-${yourls_version}/phpinfo.php" :
    ensure  => file,
    content => $phpinfo,
  }

  file {
    '/etc/systemd/system/nginx.service.d':
      ensure => directory,
  }
  unless $::nginx_pid  {
    exec {'fix_nginx.pid_error':
      path     => [ '/usr/bin', '/bin', '/usr/sbin' ],
      provider => shell,
      command  => 'printf "[Service]\\nExecStartPost=/bin/sleep 0.1\\n" > /etc/systemd/system/nginx.service.d/override.conf; systemctl daemon-reload; systemctl restart nginx ',
    }
  }
  # Compile nginx
  unless $::yourls_config  {
    exec {'compile':
      path     => [ '/usr/bin', '/bin', '/usr/sbin' ],
      cwd      => "/usr/src/nginx-${nginx_version}/",
      provider => shell,
      command  => "./configure --prefix=/usr/share/nginx --sbin-path=/usr/sbin/nginx --modules-path=/usr/lib64/nginx/modules --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --http-client-body-temp-path=/var/lib/nginx/tmp/client_body --http-proxy-temp-path=/var/lib/nginx/tmp/proxy --http-fastcgi-temp-path=/var/lib/nginx/tmp/fastcgi --http-uwsgi-temp-path=/var/lib/nginx/tmp/uwsgi --http-scgi-temp-path=/var/lib/nginx/tmp/scgi --pid-path=/run/nginx.pid --lock-path=/run/lock/subsys/nginx --user=nginx --group=nginx --with-file-aio --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-stream_ssl_preread_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_degradation_module --with-http_slice_module --with-http_stub_status_module --with-http_auth_request_module --with-mail=dynamic --with-mail_ssl_module --with-pcre --with-pcre-jit --with-stream=dynamic --with-stream_realip_module --with-stream_ssl_module --add-module=/usr/src/nginx-${nginx_version}/nginx-auth-ldap; make; make install",
      timeout  => 900,
      # onlyif   => 'test -e /usr/src/nginx-1.22.1/configure'
    }
    file { "/etc/nginx/YOURLS-${yourls_version}/shorten/index.php":
    ensure  => present,
    source  => '/tmp/index.php',
    replace => 'yes',
    }
    file { "/etc/nginx/YOURLS-${yourls_version}/index.html":
    ensure  => present,
    source  => '/tmp/index.html',
    replace => 'yes',
    }
    file { "/etc/nginx/YOURLS-${yourls_version}/user/config.php":
    ensure  => present,
    source  => '/tmp/config.php',
    replace => 'yes',
    }
    file { "/etc/nginx/YOURLS-${yourls_version}/.htaccess":
    ensure  => present,
    source  => '/tmp/htaccess',
    replace => 'yes',
    }
    file { '/etc/nginx/conf.d/yourls.conf':
    ensure  => present,
    source  => '/tmp/yourls_config_new.txt',
    replace => 'yes',
    }
    file { '/etc/nginx/nginx.conf':
    ensure  => present,
    source  => '/tmp/nginx_conf.txt',
    replace => 'yes',
    }
  }
# Daily DB backup.
  class { 'mysql::server::backup':
    backupuser          => $yourls_db_user_hide.unwrap,
    backuppassword      => $yourls_db_pass_hide.unwrap,
    provider            => 'mysqldump',
    incremental_backups => false,
    backupdir           => '/tmp/backups',
    backuprotate        => 5,
    execpath            => '/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin',
    time                => ['23', '50'],
  }
}
