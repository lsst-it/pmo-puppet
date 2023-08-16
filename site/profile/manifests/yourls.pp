# URL Shortener
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
  }
  archive { '/tmp/mysql-db-yourls.gz' :
    ensure  => present,
    source  => 's3://yourls-data/yourls/20230816030002-yourls-php-info.tgz',
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
