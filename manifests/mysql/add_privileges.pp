define pp::mysql::add_privileges (
  $databases,
  $users            = 'all',
  $pma_server       = $::pma_server,
  $privileges       = [ 'all' ],
  $permission_hash  = $::mysql_permission_new,
  $pma              = true,
){
  if $::mysql_enable {
    mysql::db { $databases:
      ensure    => present,
      user      => $name,
      password      => $permission_hash[$name]['pass']
#     mgmt_cnf  => '/root/.my.cnf'
    }

    $users_list = keys($permission_hash)
    $users_tmp = $users + $name

    each($users_list) |$user| {
      if $users != 'all' {
        if member($users_tmp, $user) {

#          notice("notice ${user}_${databases[0]}huy")

          pp::mysql::set_privileges { "${user}_${databases[0]}":
            databases       => $databases,
            user            => $user,
            privileges      => $privileges,
            permission_hash => $permission_hash,
            pma             => $pma,
          }
        }
      } else {
#          notice("notice ${user}_${databases[0]}")
        pp::mysql::set_privileges { "${user}_${databases[0]}":
          databases       => $databases,
          user            => $user,
          privileges      => $privileges,
          permission_hash => $permission_hash,
          pma             => $pma,
        }
      }
    }
  }
}


#define pp::mysql::add_privileges (
#  $users,
#  $pma_server = $::pma_server,
#) {
#  $arr = suffix($users, "_${name}")
#  pp::add_mysql_privileges { $arr:
#    database => $name,
#    pma_server  => $pma_server
#  }  
#} 
