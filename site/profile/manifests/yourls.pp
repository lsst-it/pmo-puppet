class profile::yourls ( String

$yourls_version,
$nginx_version

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
}
