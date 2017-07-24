###############################################################################
#                                 Deploy Wallarm                              #
###############################################################################
#
# Manifest used nginx module puppet:
# https://github.com/voxpupuli/puppet-nginx
#
# For correctly work need used next parameters: 
#
#    nginx_cfg_prepend     => {
#      'load_module' => 'modules/ngx_http_wallarm_module.so'
#    },
#
#    http_cfg_append       => {
#      'wallarm_tarantool_upstream'  => 'wallarm_tarantool', #optional
#      'wallarm_mode'                => 'monitoring',
#    }
#

class pp::wallarm (
  $license_key,
  $login,
  $password,
  $wallarm_path   = [ '/usr/share/wallarm-common', '/bin' ],
  $node_name      = $::hostname,
  $key_path       = '/etc/wallarm/license.key',
  $tarantool_cfg  = '/etc/default/wallarm-tarantool',
  $wallarm_cfg    = '/etc/wallarm/node.yaml',
  $wallarm_pkg    = [ 'wallarm-node', 'nginx-module-wallarm' ],
  $tarantool_node = [ 'example.com:3313' ],
  $logoutput      = true,
  $memory         = 0.2,
){

  apt::source { 'wallarm':
    location    => 'http://repo.wallarm.com/ubuntu/wallarm-node',
    release     => "${::lsbdistcodename}/",
    key         => '7F087AE27EE44069B5D0F27D0963D54172B865FD',
    include_src => false,
    repos       => '',
  }

  package { $wallarm_pkg:
    ensure  => present,
    require => Apt::Source['wallarm']
  }

  service { 'wallarm-tarantool':
    ensure => running,
  }

  augeas { 'wallarm-tarantool':
    context => "/files/${tarantool_cfg}",
    changes => "set SLAB_ALLOC_ARENA ${memory}",
    notify  => Service['wallarm-tarantool'],
  }

  file { $key_path:
    ensure  => present,
    content => $license_key,
    mode    => '0640',
    group   => 'wallarm',
    require => Package[$wallarm_pkg],
  }

  $cmd = "addnode -u ${login} -p ${password} -n ${node_name} -b"

  exec { 'add_wallarm_node':
    path      => $wallarm_path,
    timeout   => '3000',
    command   => $cmd,
    logoutput => $logoutput,
    require   => File[$key_path],
    unless    => "grep -q ${node_name} ${wallarm_cfg}"
  }

  nginx::resource::vhost { 'localhost':
    listen_ip             => '127.0.0.8',
    index_files           => [],
    use_default_location  => false,
    access_log            => 'off',
    location_custom_cfg   => {}
  }

  nginx::resource::location { '/wallarm-status':
    ensure              => present,
    vhost               => 'localhost',
    location_custom_cfg => {
      wallarm_status  => 'on',
      allow           => [ '127.0.0.0/8' ],
      deny            => 'all'
    }
  }

  if $tarantool_node {
    nginx::resource::upstream { 'wallarm_tarantool':
      ensure  => present,
      members => $tarantool_node,
    }
  }
}
