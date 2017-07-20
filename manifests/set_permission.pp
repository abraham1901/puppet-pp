# User frendly set posix permission
#
#  Examples:
#
#  pp::set_permission_new { $write_dir :
#    permissions => {
#      'programmers'   => 'rwx',
#      'www-data'      => 'rwx',
#    },
#    other_mask  => 'r-x',
#    recursive => true,
#  }
#

define pp::set_permission (
  $permissions,
  $user_mask        = 'rwx',
  $group_mask       = 'rwx',
  $other_mask       = 'r-x',
  $mask             = 'rwx',
  $recursive        = false,
  $regular_file     = false,
  $only_default     = false,
){

  if $only_default {
    $perm = []
  } else {
    $perm = $permissions.map |$group, $mask| { "group:${group}:${mask}" }
  }

  $default_perm = $permissions.map |$group, $mask| {
    "default:group:${group}:${mask}"
  }

  $before_permission = [
    "default:user::${user_mask}",
    "default:group::${group_mask}",
    "default:mask::${mask}",
    "default:other::${other_mask}",
  ]

  $after_permission = [
    "group::${group_mask}",
    "other::${other_mask}",
    "user::${user_mask}",
    "mask::${mask}"
  ]

  if $regular_file {
    $permission = $perm + $after_permission
  } else {
    $permission = $before_permission + $perm + $default_perm + $after_permission
  }

  acl { $name:
    action     => exact,
    permission => $permission,
    require    => [
      Package[ 'acl'],
    ],
    recursive  => $recursive,
  }
      
}
