class pp::backup (
  $mysql            = false,
  $bacula_client    = true,
  $backup_files     = undef,
  $bacula_schedule  = "daily-schedule200",
  $director_password,
  $director_server,
  $storage_server,
) {
  if $bacula_client {

    class { 'bacula':
      director_password => $director_password,
      director_server   => $director_server,
      is_client         => true,
      storage_server    => $storage_server,
    }

    @@bacula::client::config { $::fqdn:
      client_schedule   => $bacula_schedule,
      director_password => $director_password,
      director_server   => $director_server,
      fileset           => "${fqdn}_files",
      storage_server    => $storage_server,
      run_scripts         => [ {
        'Command'       => '/usr/bin/vbackup 0',
        'RunsOnClient'  => 'Yes',
        'RunsWhen'      => 'Before',
     }, {
        'Command'       => 'rm -Rf /tmp/bacula',
        'RunsOnClient'  => 'Yes',
        'RunsWhen'      => 'After',
     } ]
    }

    if $backup_files != undef {
      $tmp_backup_files = $backup_files + [ '/tmp/bacula/' ]
    } else {
      $tmp_backup_files = [ '/tmp/bacula/' ]
    }

    validate_array($tmp_backup_files)

     @@bacula::director::fileset { "${fqdn}_files":
      include_files => $tmp_backup_files
    }
  }

  package { 'vbackup':
    ensure => installed
  }

  file { '/etc/vbackup/backup.0':
    ensure => directory,
    require => Package[ 'vbackup' ],
  }

  file { '/etc/vbackup/backup.0/20-dpkg.dpkg':
    ensure  => present,
    content => 'DESTDIR="dpkg/"',
    mode  => '0600',
    owner => 'root',
  }

  if $::virtual == 'physical' {
    file { '/etc/vbackup/backup.0/25-mbr.mbr':
      ensure  => present,
      content => 'DISKS=""
DESTDIR="mbr/"
DESTFILE="mbrs.%D1%"',
      mode  => '0600',
      owner => 'root',
    }
  } else {
      file { '/etc/vbackup/backup.0/25-mbr.mbr':
        ensure => absent,
      }
    
  
  }


  if $mysql {
    file { '/etc/vbackup/backup.0/30-mysql.mysql':
      ensure  => present,
      content => "PASSWORD=\"${::admin_password}\"
MYUSER=\"root\"
DATABASES=\"-\"
DESTDIR=\"mysql/%D1%\"",
      mode  => '0600',
      owner => 'root',
    }
  }

  file { '/etc/vbackup/backup.0/50-tar.tar':
    ensure  => present,
    content => 'DIRS=\'/var/spool/cron/crontabs/ /etc /boot\'
LEVEL=0
STATEDIR="/var/lib/vbackup/state/tar"
DESTDIR="fs/%D1%"
',
    mode  => '0600',
    owner => 'root',
  }

  file { '/etc/vbackup/backup.0/vbackup.conf':
    ensure  => present,
    content => '# Per backup global configuration file
#
# This file holds per-backup configuration options

# A directory where backups will be stored
# All other DESTDIR directives are relative to this one
DESTDIR0=/tmp/bacula/

# Compress backups? (yes/no)
COMPRESS="no"
',
    mode  => '0600',
    owner => 'root',
  }



}




