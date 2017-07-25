#
# Security check package list on Linux
#

class pp::pkg_check (
  $admin_mail = 'undef@undef',
  $hour       = '1',
  $minute     = '0',
){

  vcsrepo { '/usr/share/vulners':
    ensure    => present,
    provider  => git,
    source    => 'https://github.com/videns/vulners-scanner.git',
  }

  file{'/usr/share/vulners/pkg_check.sh':
    ensure  => present,
    content => template("${module_name}/pkg_check.sh.erb"),
    mode    => '0740',
    require => Vcsrepo['/usr/share/vulners'],
  }

  cron { 'pkg_check':
    command => '/usr/share/vulners/pkg_check.sh >/dev/null 2>&1',
    user    => root,
    hour    => $hour,
    minute  => $minute,
  }
}
