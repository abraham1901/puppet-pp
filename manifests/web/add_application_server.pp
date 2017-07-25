# Deploy php-fpm service
define pp::web::add_application_server (
  $project          = 'pp',
  $backend_port     = 9000,
  $pool_cfg_append  = undef,
  $version          = '5',
  $fpm_slow_log     = false,
  $chroot           = false,
) {

  case $version {
    '5': {
      nginxphp::fpmconfig { $name:
        php_devmode               => false,
        fpm_listen                => "127.0.0.1:${backend_port}",
        fpm_user                  => 'www-data',
        fpm_group                 => 'www-data',
        fpm_allowed_clients       => '',
        fpm_max_children          => '10000',
        fpm_start_servers         => '20',
        fpm_min_spare_servers     => '10',
        fpm_max_spare_servers     => '100',
        fpm_catch_workers_output  => true,
        fpm_error_log             => true,
        fpm_log_level             => 'NOTICE',
        fpm_rlimit_files          => 20480,
        fpm_rlimit_core           => unlimited,
        pool_cfg_append           => $pool_cfg_append,
      }
      if $fpm_slow_log {
        Nginxphp::Fpmconfig[$name] {
          fpm_slow_log => $fpm_slow_log
        }
      }
    }
    '5.6': {
      nginxphp6::fpmconfig { $name:
        php_devmode               => false,
        fpm_listen                => "127.0.0.1:${backend_port}",
        fpm_user                  => 'www-data',
        fpm_group                 => 'www-data',
        fpm_allowed_clients       => '',
        fpm_max_children          => '10000',
        fpm_start_servers         => '20',
        fpm_min_spare_servers     => '10',
        fpm_max_spare_servers     => '100',
        fpm_catch_workers_output  => true,
        fpm_error_log             => true,
        fpm_log_level             => 'NOTICE',
        fpm_rlimit_files          => 20480,
        fpm_rlimit_core           => unlimited,
        pool_cfg_append           => $pool_cfg_append,
      }
      if $fpm_slow_log {
        Nginxphp6::Fpmconfig[$name] {
          fpm_slow_log => $fpm_slow_log
        }
      }
    }
    '7': {
      nginxphp7::fpmconfig { $name:
        php_devmode               => false,
        fpm_listen                => "127.0.0.1:${backend_port}",
        fpm_user                  => 'www-data',
        fpm_group                 => 'www-data',
        fpm_allowed_clients       => '',
        fpm_max_children          => '10000',
        fpm_start_servers         => '20',
        fpm_min_spare_servers     => '10',
        fpm_max_spare_servers     => '100',
        fpm_catch_workers_output  => true,
        fpm_error_log             => true,
        fpm_log_level             => 'NOTICE',
        fpm_rlimit_files          => 20480,
        fpm_rlimit_core           => unlimited,
        chroot                    => $chroot,
        pool_cfg_append           => $pool_cfg_append,
      }
      if $fpm_slow_log {
        Nginxphp7::Fpmconfig[$name] {
          fpm_slow_log => $fpm_slow_log
        }
      }
    }
    default: {
      $not_support_msg = "not support php ${version}"
      warning("Module pp::web::add_application_server ${not_support_msg}")
    }
  }
}


