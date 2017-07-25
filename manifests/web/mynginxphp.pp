#Deploy php-fpm abstract class
class pp::web::mynginxphp  (
  $packages         = [],
  $version          = '5',
  $static_packages  =  [
      'php5-curl',
      'php5-gd',
      'php-apc',
      'php5-memcached',
      'php5-mcrypt',
      'php5-imap',
      'php5-mysql',
  ],
){

  $real_packages = $static_packages + $packages

  case $version {
    '5': {
      class { 'nginxphp::php':
        php_packages => $real_packages,
      }
    }
    '5.6': {
      class { 'nginxphp6::php':
        php_packages => $real_packages,
      }
    }
    '7': {
      class { 'nginxphp7::php':
        php_packages => $real_packages,
      }
    }
    default: {
      $not_support_msg = "not support php ${version}"
      warning("Module pp::web::add_application_server ${not_support_msg}")
    }
  }
}


