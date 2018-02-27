define pp::mysql::set_privileges (
  $user,
  $databases,
  $privileges,
  $permission_hash,
  $pma_server = $::pma_server,
  $pma = true,
) {
  $tmp_priv = $permission_hash[$user]['priv']

  if $tmp_priv != '' {
    $priv = $permission_hash[$user]['priv']
  } else {
    $priv = $privileges
  }

  if size($databases) > 0 {
    each($databases) |$database| {
      if $pma {
        mysql_grant {
          "${user}@${pma_server}/${database}.*":
            ensure     => 'present',
            options    => ['GRANT'],
            privileges => [ 'ALL' ],
            table      => "${database}.*",
            user       => "${user}@{pma_server}",
        
        }
      }
    
      each($permission_hash[$user]['ips']) |$ip| {
        mysql_grant { 
          "${user}@${ip}/${database}.*":
            ensure     => 'present',
            options    => ['GRANT'],
            privileges => [ 'ALL' ],
            table      => "${database}.*",
            user       => "${user}@${ip}",
        
        } 
        if (!defined(Mysql_user["${user}@${ip}"])) {
          mysql_user {
            "${user}@${ip}":
              ensure                   => 'present',
              password_hash            => mysql_password($permission_hash[$user]['pass'])
          
          }
        }
      }
    }
  }
}

