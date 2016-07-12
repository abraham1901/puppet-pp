#Deploy php-fpm abstract class
class pp::web::mynginxphp  (
  $packages = [],
  $static_packages =  [
      'php5-curl',
      'php5-gd',
      'php-apc',
      'php5-memcached',
      'php5-mcrypt',
      'php5-imap',
      'php5-mysql',
    ],
  $version = '5'
){

  $real_packages = $static_packages + $packages

  case $version {
    '5': {
      class { 'nginxphp::php':
        php_packages => $real_packages,
      }
    }
    '7': {
      class { 'nginxphp7::php':
        php_packages => $real_packages,
      }
    }
    default: {
      warning("Module pp::web::add_application_server not support php ${version}")
    }
  }
}


